function [rawResponse] = measurement_io(playChan,recChan,Fs,stimulus)
%MEASUREMENT_IO     provides the interface between getSysIR and the playrec
%utility
%
%[rawResponse] = measurement_io(playChan,recChan,Fs,stimulus);
%       playChan:   vector of channels to play on
%       recChan:    vector of channels to record on
%       Fs:         sampling frequency (Hz)
%       stimulus:   column vector containing stimulus signal to be output
%       on channels specified in playChan
%
%Alastair Moore, September 2006


%loopback_playChan = 4;
%loopback_recChan = 4;
recExtend = 4000; %value taken blindly from original acqdata.m
loopback = 0;       %default value
loopback_mls_order = 12;
loopback_reps = 4;


%Default values are hard wired by loading DeviceConfig.mat.  It's values
%are stored as fields in the deviceConfig structure
deviceConfig = getAudioDeviceIOSettings();


%check that none of the specified playback or rec channels are the same
%as the loopback channel
if deviceConfig.loopback

    loopback = 1;
    nChan = length(playChan);
    nUniqueChans = length(find(playChan - deviceConfig.loopback_out_chan));
    if nUniqueChans ~= nChan
        warning('Conflicting output channels specified. Loopback not used. Run "configureDevices" to choose a different loopback channel.');
            deviceConfig.loopback_out_chan
        playChan
        loopback = 0;
    end
    
    nChan = length(recChan);
    nUniqueChans = length(find(recChan - deviceConfig.loopback_in_chan));
    if nUniqueChans ~= nChan
        warning('Conflicting input channels specified. Loopback not used. Run "configureDevices" to choose a different loopback channel.');
            deviceConfig.loopback_in_chan
        recChan
        loopback = 0;
    end
end
    

%setup recording channels
nReqSamples = length(stimulus)

if loopback
    disp(['Doing loopback from chan ' num2str(deviceConfig.loopback_out_chan) ...
        ' to chan ' num2str(deviceConfig.loopback_in_chan)])
    disp(['Play channel(s):' num2str(playChan)])
    
    %Produce a signal with which to measure the loopback delay
    loopback_out = zeros(nReqSamples,1);
    % - unit impulse
    %loopback_out(1) = 1;
    
    % - mls sequence
    if nReqSamples < loopback_reps * (2^loopback_mls_order - 1) %check mls will fit
        %if not, reduce length of loopback signal to fit inside nReqSamples
        loopback_mls_order = fix(log2(nReqSamples / loopback_reps));
        if loopback_mls_order < 1
            disp('loopback signal seems too short')
            keyboard
        end
    end
    mls_signal = mls('generate',{loopback_mls_order,loopback_reps,1,loopback_reps,0});
    loopback_out(1:length(mls_signal)) = 0.01 * mls_signal;
        

    
    %add loopback to stimulus
    outSignal = [stimulus,loopback_out];
    playChan(end+1) = deviceConfig.loopback_out_chan;
    recChan(end+1) = deviceConfig.loopback_in_chan;
else
    outSignal = stimulus;
end


%Check initialisation
%{
if playrec('isInitialised')~=1
    playrec('init', Fs, deviceConfig.outputDeviceID, deviceConfig.inputDeviceID);
end

if ((Fs~=playrec('getSampleRate')) || ...
    (deviceConfig.outputDeviceID~=playrec('getPlayDevice')) || ...
    (deviceConfig.inputDeviceID~=playrec('getRecDevice')))
    
    error('playrec is not configured to use the same configuration as required');
end
%}
check_playrec_init(Fs,deviceConfig.outputDeviceID, deviceConfig.inputDeviceID,...
    [],[],[],1);

%construct the output/input 'page' and then execute it in blocking mode
pageNum = playrec('playrec', outSignal, playChan, length(outSignal)+recExtend, recChan);
playrec('block', pageNum);

%extract the recorded data and tidy up
[recSignal recChanOrder] = playrec('getRec', pageNum);
playrec('delPage', pageNum);

%playrec('reset');   %this avoids wasting processing power used filling buffers with zero

%check to make sure playrec has not changed the order of record channels
if recChanOrder~=recChan
    error('Recording channels got mixed up!')
end

if loopback
    %use the loopback channel to determine the delay by finding the maximum
    %value of the impulse response measured using mls signal
    loopback_in = recSignal(:,end);
    if max(abs(loopback_in)) < 0.01;
        warning('Loopback signal in is < -20 dBFS... turn up the input gain');
        fprintf('Press return to continue')
        pause()
    end
    loopback_ir = mls('process',{loopback_mls_order,loopback_reps,1,loopback_reps,0},loopback_in);   
    %plotvstime(loopback_ir);
    [max_val indices] = max(abs(loopback_ir));
    delay = indices(1)-1           %first occurence of max_val gives the 
                                    %number of samples delay offset by 1
    
    if delay < 1
        warning('measurement_io: delay is negative, set to zero!')
        keyboard
    end
    
    %crop the delay from the start and return recorded samples (but not the
    %loopback channel)
    if delay < recExtend
        rawResponse = recSignal((1+delay):(nReqSamples+delay),1:end-1);
    else
        error('measurement_io: recExtend is smaller than delay');
    end
    
else
    rawResponse = recSignal(1:nReqSamples,:);
end
%playrec('reset')


