function[deviceConfig] = getAudioDeviceIOSettings(filepath)
% Returns a structure containing saved settings
%
% Order of precedence
%   filepath
%   AHM_IR_MEASUREMENT_ROOT/deviceConfig.mat
%   deviceConfig.mat anywhere on path


%Default values are hard wired by loading DeviceConfig.mat.  It's values
%are stored as fields in the deviceConfig structure

if nargin && ~isempty(filepath)
    config_path = filepath;
elseif exist('AHM_IR_MEASUREMENT_ROOT','var')
    config_path = fullfile(AHM_IR_MEASUREMENT_ROOT,'DeviceConfig.mat');
else
    config_path = 'DeviceConfig.mat';
end

fprintf('Loading %s\n',config_path);

if exist(config_path,'file')
    load(config_path,'deviceConfig')
else
    error('No file at %s\nChoose the devices to use by running "configureDevices"',config_path)
end

% Sanity check
% in liu of proper checking of specified device names
if ~isequal(deviceConfig.devices,playrec('getDevices'))
    warning('Audio devices have changed. Run "configureDevices".')
    % TODO: compare the device names - maybe we can find the required devices
end
