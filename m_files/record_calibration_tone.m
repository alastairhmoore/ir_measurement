function[tone, calibration_level_db] = record_calibration_tone(recChan,pistonphone_spl_db,pistonphone_freq_Hz)
%
%             recChan: channel to record
%  pistonphone_spl_db: sound pressure level of pistonphone
% pistonphone_freq_Hz: frequency of pistonphone tone

record_duration_s = 3;
maximum_peak_db_fs = -1;

if numel(recChan)~=1
    error('Record one channel at a time')
end



%Default values are hard wired by loading DeviceConfig.mat.  It's values
%are stored as fields in the deviceConfig structure
deviceConfig = getAudioDeviceIOSettings();


%
fs = deviceConfig.fs;
num_required_samples = ceil(fs*record_duration_s);

check_playrec_init(fs, ...      % required sample rate
                   [], ...      % output device (not required)
                   deviceConfig.inputDeviceID, ...
                   [],...       % minPlayChans
                   recChan,...  % minRecChans,
                   [],...       % framesPerBuffer
                   1);          % change settings to match requirements

%construct the output/input 'page' and then execute it in blocking mode
pageNum = playrec('rec', num_required_samples, recChan);
playrec('block', pageNum);

%extract the recorded data and tidy up
[recSignal, recChanOrder] = playrec('getRec', pageNum);
playrec('delPage', pageNum);

%check to make sure playrec has not changed the order of record channels
if recChanOrder~=recChan
    error('Recording channels got mixed up!')
end

if size(recSignal,1) ~= num_required_samples
    error('Wrong number of samples returned')
end

peak_db_fs = 20*log10(max(abs(recSignal)))
if peak_db_fs > maximum_peak_db_fs
    error('Peak signal (%2.1 dB) exceeds threshold (%2.2f dB)\n',...
        peak_db_fs,maximum_peak_db_fs)
end

if 1
    figure;
    tscale = (1:num_required_samples).' .* (1/fs);
    plot(tscale,recSignal);
end

Tsamples = fs/pistonphone_freq_Hz;
t1 = v_zerocros(recSignal(1:Tsamples),'pr');
t2 = size(recSignal,1)-Tsamples + v_zerocros(recSignal(end-Tsamples+(1:Tsamples)),'pr');
tone = double(recSignal(t1:t2));

sinusoid_capture_level_db_fs = 20*log10(rms(tone));
calibration_level_db = pistonphone_spl_db - sinusoid_capture_level_db_fs;



