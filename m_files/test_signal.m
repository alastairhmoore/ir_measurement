function[test_rec] = test_signal(config,signal_opts,gain_opts_in)

deviceConfig = getAudioDeviceIOSettings();
fs = deviceConfig.fs;

%% Deal with inputs
% channel config is required
if nargin < 1 || isempty(config)
    error('Must specify channel configuration')
else
    [playChan, recChan] = parseChannelConfig(config);
end

% signal_opts can either be a scalar to choose from some presets or a
% structure to define the signal
if nargin < 2 || isempty(signal_opts)
    signal_opts = 1;
end
if ~isstruct(signal_opts) && isscalar(signal_opts)
    %convert scalar value to presets
    signal_opts_id = signal_opts;
    signal_opts = [];
    switch signal_opts_id
        case 1
            signal_opts.fcn_handle = @sine_tone;
            signal_opts.settings.duration = 3; %seconds
            signal_opts.settings.frequency = 1000; %Hz
        case 2
            signal_opts.fcn_handle = @white_noise;
            signal_opts.settings.duration = 3; %seconds
        otherwise
            error('Unknown scalar preset for signal_opts')
    end
end


%finally check that signal_opts has required fields
if ~isfield(signal_opts,'fcn_handle') || ~isfield(signal_opts,'settings')
    error('signal_opts must contain fields fcn_handle and settings')
end

% gain_opts should ultimately include eq filter but for now we only do gain
gain_opts.gain = 1;
if nargin > 2
    gain_opts = override_valid_fields(gain_opts,gain_opts_in);
end

%% generate mono output signal
signal = signal_opts.fcn_handle(fs, signal_opts.settings);

%% duplicate as required to fill all output channels
%send to soundcard and record response
test_rec = measurement_io(playChan,recChan,fs,repmat(gain_opts.gain*signal,1,length(playChan)));

%% do some helpful checks
show_levels = 0;
max_lev = max(abs(test_rec));
if any(max_lev > 10^(-0.5/20))
    warning('One or more channels exceeded -0.5 dBFS')
    show_levels = 1;
end
if any(max_lev < 10^(-10/20))
    warning('One or more channels has excessive headroom (> 10 dB)')
    show_levels = 1;
end
fprintf('Test signal input levels range from %2.2f to %2.2f dBFS\n',20*log10(min(max_lev(:))),20*log10(max(max_lev(:))))
for ichan = 1:length(recChan)
    fprintf('%d:\t%2.2f dB FS\n',recChan(ichan),20*log10(max_lev(ichan)));
end
if show_levels
    figure;
    word_length = 24;
    noise_floor = 20*log10(1/(2^(word_length)));
    noise_floor = floor(noise_floor/5) * 5;
    bar(-noise_floor+max(noise_floor,20*log10(max_lev)));
    ylim([0 -noise_floor]);
    set(gca,'ytick',[0:5:-noise_floor]);
    set(gca,'yticklabel',[0:5:-noise_floor]+noise_floor);
    xlim([0 length(max_lev)+1]);
    set(gca,'xtick',[1:length(max_lev)]);
    set(gca,'xticklabel',num2cell(recChan))
    xlabel('Input channel')
    ylabel('Maximum signal level [dBFS]')
end    
