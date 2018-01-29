function check_playrec_init(Fs, playDeviceID, recDeviceID, minPlayChans, minRecChans, framesPerBuffer, change_not_fail)
% check_playrec_init(Fs, outputID, inputID)
%
%   Checks that playrec is intitilised with the required settings
%
%   Fs
%   outputID
%   inputID
%

%
%Alastair Moore, November 2007 (based on code by Robert Humphrey)
% - March 2008: Completely revamped to check all options and change if
%               required and desired

%init(sampleRate, playDevice, recDevice, {playMaxChannel}, {recMaxChannel}, {framesPerBuffer})
if nargin < 7 || isempty(change_not_fail)
    change_not_fail = 1;
end

%check current configuration if there is a mismatch, either reset to allow 
%setting to be changed or fail depending on value of change_not_fail flag
if(playrec('isInitialised'))
    if(playrec('getSampleRate')~=Fs)
        if change_not_fail
            fprintf('Changing playrec sample rate from %d to %d\n', playrec('getSampleRate'), Fs);
            playrec('reset');
        else
            error('Sample rate was wrong')
        end
    elseif(nargin > 1 && ~isempty(playDeviceID) && playrec('getPlayDevice')~=playDeviceID)
        if change_not_fail
            fprintf('Changing playrec play device from %d to %d\n', playrec('getPlayDevice'), playDeviceID);
            playrec('reset');
        else
            error('Wrong play device')
        end
    elseif(nargin > 2 && ~isempty(recDeviceID) && playrec('getRecDevice')~=recDeviceID)
        if change_not_fail
            fprintf('Changing playrec record device from %d to %d\n', playrec('getRecDevice'), recDeviceID);
            playrec('reset');
        else
            error('Wrong record device')
        end
    elseif(nargin > 3 && ~isempty(minPlayChans) && playrec('getPlayMaxChannel')<minPlayChans)
        if change_not_fail
            fprintf('Resetting playrec to configure device to use more output channels\n');
            playrec('reset');
        else
            error('Not enough output channels')
        end
    elseif(nargin > 4 && ~isempty(minRecChans) && playrec('getRecMaxChannel')<minRecChans)
        if change_not_fail
            fprintf('Resetting playrec to configure device to use more input channels\n');
            playrec('reset');
        else
            error('Not enough input channels')
        end
    elseif(nargin > 5 && ~isempty(framesPerBuffer) && playrec('getFramesPerBuffer')~=framesPerBuffer)
        if change_not_fail
            fprintf('Resetting playrec to use  %d frames per buffer\n', framesPerBuffer);
            playrec('reset');
        else
            error('Wrong number of frames per buffer')
        end
    end
end

%function check_playrec_init(Fs, playDeviceID, recDeviceID, minPlayChans, minRecChans, framesPerBuffer, change_not_fail)
deviceList = playrec('getDevices');

%Initialise if not initialised
if(~playrec('isInitialised'))
    if (nargin < 2 || isempty(playDeviceID)); playDeviceID = -1; end
    if (nargin < 3 || isempty(recDeviceID));  recDeviceID = -1;   end
    if (nargin < 4 || isempty(minPlayChans))
        if playDeviceID == -1
            minPlayChans = 0;
        else
            [val i] = find([deviceList.deviceID]==playDeviceID);
            minPlayChans = deviceList(i).outputChans;
        end
    end
    if (nargin < 5 || isempty(minRecChans));
        if recDeviceID == -1
            minRecChans = 0;
        else
            [val i] = find([deviceList.deviceID]==recDeviceID);
            minRecChans = deviceList(i).inputChans;
        end
    end
    if (nargin < 6 || isempty(framesPerBuffer))
        playrec('init',Fs, playDeviceID, recDeviceID, minPlayChans, minRecChans)
    else
        playrec('init',Fs, playDeviceID, recDeviceID, minPlayChans, minRecChans, framesPerBuffer)
    end
    %TODO:  could provide feedback as to what settings are being attempted 
    %fprintf('Initialising playrec to use sample rate: %d, playDeviceID: %d and no record device\n', Fs, playDeviceID);
    %playrec('init', Fs, playDeviceID, -1)
end
    
if(~playrec('isInitialised'))
    error 'Unable to initialise playrec correctly';
    %TODO: Check which parameter caused fail
end

