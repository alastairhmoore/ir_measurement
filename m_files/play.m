function [] = play(outSignal,Fs,playChan)
%PLAY     provides a convenient wrapper for playrec when output only is 
%required
%
%play(signal,Fs,playChan);
%       signal:     vector (or matrix) of samples to play
%       Fs:         sampling frequency (Hz)
%       playChan:   vector of channels to play on
%
%Alastair Moore, July 2013

%Default values are hard wired by loading DeviceConfig.mat.  It's values
%are stored as fields in the deviceConfig structure
deviceConfig = getAudioDeviceIOSettings();

[nSamples, nChans] = size(outSignal);

%make sure channels match data
if nargin<3 | isempty(playChan)
    playChan = 1:nChans;
else
    if length(playChan)<nChans
        outSignal = outSignal(:,1:nChans);
    else
        if length(playChan)>nChans
            if nChans == 1
                outSignal = repmat(outSignal,1,length(playChan));
            else
                playChan = playChan(1:nChans);
            end
        end
    end
end


check_playrec_init(Fs,deviceConfig.outputDeviceID, deviceConfig.inputDeviceID,...
    [],[],[],1);

%construct the output/input 'page' and then execute it in blocking mode
pageNum = playrec('play', outSignal, playChan);
playrec('block', pageNum);



