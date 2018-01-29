function [ od, id, s ] = get_playrec_devices_by_api( api )
%GET_PLAYREC_DEVICES_BY_API returns playrec device ids
%   Inputs:
%           api:    string specifying the desired api
%
%   Outputs:
%            od:	Output device >=0 or -1 if no devices available
%            id:    Input device >=0 or -1 if no devices available
%             s:    structure containing device information for all devices
%                    s(od+1) has information about the output devices with
%                    fields: 'name','hostAPI','defaultLowInputLatency','defaultLowOutputLatency'
%                        'defaultHighInputLatency','defaultHighOutputLatency','defaultSampleRate'
%                        'inputChans','outputChans'

s = playrec('getDevices');
s = s(strcmp({s.hostAPI},api));


i_outputs = find([s.outputChans]>0);
i_inputs = find([s.inputChans]>0);

if ~isempty(i_outputs)
    od = [s(i_outputs).deviceID].';
else
    od = -1;
end

if ~isempty(i_inputs)
    id = [s(i_inputs).deviceID].';
else
    id = -1;
end


