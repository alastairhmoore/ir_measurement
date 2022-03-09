function[deviceConfig] = getAudioDeviceIOSettings(filepath)
% Returns a structure containing saved settings
%
% Order of precedence
%   filepath
%   pwd/DeviceConfig.mat
%   AHM_IR_MEASUREMENT_ROOT/DeviceConfig.mat


%Default values are hard wired by loading DeviceConfig.mat.  It's values
%are stored as fields in the deviceConfig structure

config_path = [];
search_id = 0;
while isempty(config_path) && search_id < 4
    search_id=search_id+1;
    switch search_id
        case 1
            if nargin < 1 
                filepath = [];
            end
        case 2
            filepath = fullfile(pwd,'DeviceConfig.mat');
        case 3
            filepath = fullfile(fileparts(mfilename()),'DeviceConfig.mat');
    end
    if ~isempty(filepath) && exist(filepath,'file')
        config_path = filepath;
    end
end


if isempty(config_path)
    error('No device config file was found.\nChoose the devices to use by running "configureDevices"')
end

fprintf('Loading %s\n',config_path);
load(config_path,'deviceConfig')

% Sanity check
% in liu of proper checking of specified device names
if ~isequal(deviceConfig.devices,playrec('getDevices'))
    warning('Audio devices have changed. Run "configureDevices".')
    % TODO: compare the device names - maybe we can find the required devices
end
