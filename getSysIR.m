function[impulse_response, extras] = getSysIR(config, signal_opts, gain_opts, process_opts)
%GETSYSIR measures the acoustic impulse response of a system by outputing a
%test signal to the soundcard and recording and processing the response.
%
%impulse_response = getSysIR()
%       uses the default settings:
%           ouput:  Channel 1
%           input:  Channels 1 & 2
%           signal: sweptsine from 20 Hz
%           gain:   1
%
%impulse_response = getSysIR(config)
%       config specifies the input/output configurations.  The following
%       strings can be used for a standard arrangement using the 1st stereo
%       input/output pair of the soundcard.
%           'hrtf':     1 out/2 in
%           'phones:    2 out/2 in
%       Otherwise a two cell array can be passed.  The first element is a
%       vector specifying the output channels.  The second specifies the
%       input channels.
%
%impulse_response = getSysIR(config, signal_opts)
%       Optional argument signal_opts can contain the following fields
%         fcn_handle: a function handle to a function whose first argument 
%                     can be 'generate' or 'process'.  These respectively
%                     return a stimulus signal and an impulse response.
%           settings: an variable containing parameters which are
%                     particular to the chosen signal type
%
%       If singal_opts is left empty it defaults to
%          fcn_handle = @sweptsine
%            settings = {20,fs/2,0.6,fs}
%
%impulse_response = getSysIR(config, signal_opts,gain_opts)
%       Optional argument gain_opts can contain the following fields
%               gain: specifies a linear gain to be applied to the stimulus
%                     signal before outputting to the soundcard. This is 
%                     accounted for during the processing such that the
%                     amplitude of impulse_response is not affected.
%                     [Default: 1]
%        pre_eq_file: filepath of a wavfile which contains the FIR filter
%                     taps to convolve with the stimulus before outputting 
%                     to the soundcard. This will be resampled to the
%                     stimulus sampling frequency as required.
%                     [Default: empty]
%
%impulse_response = getSysIR(config, signal_opts,gain_opts,process_opts)
%       Optional argument process_opts can contain the following fields
%       channel_mask: specifies which channels of recording to compute the 
%                     ir for. Only processing a subset of the channels
%                     decreases the cimputation time after each
%                     measurement. Be sure to save the 'extras' output
%                     structure so that the IRs can be computed offline
%                     [Default: ones(size(config{2})]
%      plot_raw_mask: specifies which channels of recording to plot the
%                     recorded waveform for
% plot_raw_decimate_ratio: reduce the number of datapoints in plot to speed
%                     up
%                     [Default: 1]
%
%[impulse_response, extras] = getSysIR(config, signal_opts,gain_opts)
%       Optional output extras contains a number of potentially interesting
%       internal parameters
%
%Alastair Moore, September 2006
%
%Revised May 2014, April 2015

%debugging/analysis
show_plots = 0;
show_system_response = 0;

%load in device configuration so that we know the sampling rate
deviceConfig = getAudioDeviceIOSettings();
fs = deviceConfig.fs;

%% Default parameters
default_signal_opts.fcn_handle = @sweptsine;              %sweptsine
default_signal_opts.settings = {20,fs/2,0.6,fs}            % f_start,f_stop,seconds/octave,fs
default_gain_opts.gain = 1;
default_gain_opts.pre_eq_file = [];
default_process_opts.channel_mask = [];
default_process_opts.plot_raw_mask = [];
default_process_opts.plot_raw_decimate_ratio = 1;

%% Deal with inputs
% channel config is required
if nargin < 1 || isempty(config)
    error('Must specify channel configuration')
else
    [playChan, recChan] = parseChannelConfig(config);
end

if (nargin > 1)
    signal_opts = override_valid_fields(default_signal_opts,signal_opts);
else
    signal_opts = default_signal_opts;
end

if (nargin > 2)
    gain_opts = override_valid_fields(default_gain_opts,gain_opts);
else
    gain_opts = default_gain_opts;
end

if (nargin > 3)
    process_opts = override_valid_fields(default_process_opts,process_opts);
else
    process_opts=default_process_opts;
end

if isempty(process_opts.channel_mask)
    process_opts.channel_mask = ones(size(recChan));
else
    if ~isequal(size(process_opts.channel_mask),size(recChan))
        error('Dimensions of process_opts.channel_mask must match exactly the size of config{2}')
    end
    if any(process_opts.channel_mask==0)
        warning(['Returned impulse response has missing channels!\n',...
                 'Use extras.rawResponse to calculate full ir'])
        if nargout < 2
            error('Cannot allow ir with missing channels without also returning extras')
        end
    end
end
if isempty(process_opts.plot_raw_mask)
    process_opts.plot_raw_mask = ones(size(recChan));
end


% Preprocessing of pre equalisation filter
if isempty(gain_opts.pre_eq_file)
    do_preEQ = 0;
else
    [preEQ_h, preEQ_fs] = wavread(gain_opts.pre_eq_file);
    if ~isequal(preEQ_fs,fs)
        preEQ_h = resample(preEQ_h,fs,preEQ_fs);
    end
    do_preEQ = 1;
end

%% Generate the test signal
stimulus = gain_opts.gain * signal_opts.fcn_handle('generate',signal_opts.settings);
if do_preEQ
    original_length = length(stimulus);
    stimulus = fftfilt(preEQ_h,[stimulus;zeros(length(preEQ_h)-1,1)]); %filter zeropadded version to keep tail
end
stimulus = repmat(stimulus,1,length(playChan));

if show_plots;figure; plot([1/Fs:1/Fs:length(stimulus)/fs],stimulus);title('Stimulus signal');xlabel('Time [s]');ylabel('Amplitude [linear]');end

%% Do the measurment
rawResponse = measurement_io(playChan, recChan, fs, stimulus);
max_lev = 20*log10(max(abs(rawResponse)));
fprintf('Peak levels:\n')
for ii=1:length(max_lev);fprintf('%2d: %02.2f dBFS\n',recChan(ii),max_lev(ii));end
if any(max_lev >= 0);warning('Signal may have clipped!!');end

if do_preEQ
    rawResponse(original_length+1:end,:) = []; %remove tail due to preEQ
end

if show_plots || any(process_opts.plot_raw_mask);
    figure;
    step = default_process_opts.plot_raw_decimate_ratio;
    plot([1:step:length(rawResponse)]./fs,rawResponse(1:step:end,process_opts.plot_raw_mask==1));
    title('Raw system response');
    xlabel('Time [s]');
    ylabel('Amplitude [linear]');
end

%% Process to get ir
[impulse_response, ir_extras] = signal_opts.fcn_handle('process',signal_opts.settings,rawResponse(:,process_opts.channel_mask==1));
impulse_response = (1/gain_opts.gain) * impulse_response;

if nargout>1
    extras.fs = fs;
    extras.config = {playChan,recChan};
    extras.signal_opts = signal_opts;
    extras.gain_opts = gain_opts;
    extras.stimulus = stimulus(:,1);
    extras.rawResponse = rawResponse;
    extras.ir_extras = ir_extras;
end

    



%% Ploting of results if on
if show_plots; figure; plot([1/fs:1/fs:length(impulse_response)/fs],impulse_response);title('Impulse response');xlabel('Time [s]');ylabel('Amplitude [linear]');end
if show_plots || show_system_response
    figure;
    subplot(211)
    plot(linspace(1/fs,length(impulse_response)/fs,length(impulse_response)),impulse_response)
    title('Impulse response')
    xlabel('Time [s]')
    ylabel('Amplitude [linear]')
    subplot(212)
    plot(linspace(fs/length(impulse_response),fs,length(impulse_response)),20*log10(abs(fft(impulse_response))));
    xlabel('Frequency [Hz]')
    ylabel('Amplitude [dB]')
end
%%




