function[deviceConfig] = getAudioDeviceIOSettings(filepath)


%Default values are hard wired by loading DeviceConfig.mat.  It's values
%are stored as fields in the deviceConfig structure
if exist('DeviceConfig.mat','file')
    load DeviceConfig.mat
    if ~isequal(deviceConfig.devices,playrec('getDevices'))
        warning('Audio devices have changed. Run "configureDevices".')
    end
else
    error('Choose the devices to use by running "configureDevices"')
end