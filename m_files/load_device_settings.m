%load_device_settings script checks that DeviceConfig.mat exists, loads it
%and enusres it is compatible with the currently connected devices
%
%deviceConfig is added to the workspace

if exist('DeviceConfig.mat','file')
    load DeviceConfig.mat
    if ~isequal(deviceConfig.devices,playrec('getDevices'))
        warning('Audio devices have changed. Run "configureDevices".')
    end
else
    error('Choose the devices to use by running "configureDevices"')
end