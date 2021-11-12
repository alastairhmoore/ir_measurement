function varargout = configureDevices(varargin)
%CONFIGUREDEVICES M-file for configureDevices.fig
%      CONFIGUREDEVICES, by itself, creates a new CONFIGUREDEVICES or raises the existing
%      singleton*.
%
%      H = CONFIGUREDEVICES returns the handle to a new CONFIGUREDEVICES or the handle to
%      the existing singleton*.
%
%      CONFIGUREDEVICES('Property','Value',...) creates a new CONFIGUREDEVICES using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to configureDevices_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CONFIGUREDEVICES('CALLBACK') and CONFIGUREDEVICES('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CONFIGUREDEVICES.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help configureDevices

% Last Modified by GUIDE v2.5 29-May-2014 10:54:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @configureDevices_OpeningFcn, ...
                   'gui_OutputFcn',  @configureDevices_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before configureDevices is made visible.
function configureDevices_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for configureDevices
handles.output = 0;

% Set background colors properly
set(findobj(handles.figure1,'type','uicontrol'),'BackgroundColor',get(handles.figure1,'Color'))


handles.all_sample_rates = [8000,16000,20000,32000,44100,48000,96000,192000]';
handles.default_sample_rate = 48000;

%get the directory where this mfile is
dir_path = fileparts(which(mfilename));
handles.save_path = fullfile(dir_path, 'DeviceConfig.mat');

%TODO: Check for previously saved config file and prepopulate
p = inputParser;
p.FunctionName = 'configureDevices';
%p.addParameter('save_path',save_path,@(x)validateattributes(x,{'string'},{'scalartext'}));
%p.addOptional('load_path',handles.save_path);
p.addOptional('load_path',handles.save_path,@(s)ischar(s));
if numel(varargin) > 0
    input_args = varargin{1}; % hack because we had to wrap inputs in a cell
else
    input_args = {};
end
parse(p, input_args{:});
handles.load_path = p.Results.load_path;
[parentdir,fname,ext] = fileparts(handles.load_path);
if isempty(ext) || ~strcmp(ext,'.mat')
    handles.load_path = [handles.load_path '.mat'];
end

%%
handles.savedDeviceConfig = []; 
fprintf('Looking for saved config file at:\n%s\n\n',handles.load_path);
if exist(handles.load_path,'file')
    savedDeviceConfig = load(handles.load_path,'deviceConfig')
    handles.savedDeviceConfig = savedDeviceConfig.deviceConfig;
end

%populate the api menu - only happens once
s = playrec('getDevices');
available_apis = unique({s.hostAPI});
%TODO?: apply preferred ordering of apis on windows
set(handles.audio_api_popupmenu,'string',available_apis);
set(handles.audio_api_popupmenu,'value',1);

% if saved config is available, get the parameter and match it with
% available
if ~isempty(handles.savedDeviceConfig)
    if ~select_popupmenu_entry(handles.audio_api_popupmenu,...
                                   get_saved_data(handles,'audio_api'))
        warning('couldn''t restore audio api - ignoring saved config')
        handles.savedConfig = [];
    end
end

% keep track of gui state
handles.is_initialised = struct('devices',0,'device_settings',0);

% Update handles structure
guidata(hObject, handles);

%update the list of device options, other ui elements will update is due course
populate_device_menus(hObject,handles)

handles = guidata(hObject);





% UIWAIT makes configureDevices wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = configureDevices_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1)


% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%TODO: Validation that chosen devices actually have required capabilities

deviceConfig.devices = handles.devices;

% i_in = get(handles.in_device_id_popupmenu,'Value');
% string_cell = get(handles.in_device_id_popupmenu,'String');
% deviceConfig.inputDeviceID = str2num(cell2mat(string_cell(i_in)));
% 
% i_out = get(handles.out_device_id_popupmenu,'Value');
% string_cell = get(handles.out_device_id_popupmenu,'String');
% deviceConfig.outputDeviceID = str2num(cell2mat(string_cell(i_out)));

deviceConfig.inputDeviceID = handles.s_in.deviceID;
deviceConfig.outputDeviceID = handles.s_out.deviceID;
deviceConfig.fs = str2double(get_popupmenu_selected_string(...
                    handles.sample_rate_popupmenu));
deviceConfig.loopback = get(handles.loopback_checkbox, 'Value');

if deviceConfig.loopback == 1
    deviceConfig.loopback_in_chan = str2double(get_popupmenu_selected_string(...
                    handles.loopback_in_chan_popupmenu));
    deviceConfig.loopback_out_chan = str2double(get_popupmenu_selected_string(...
                    handles.loopback_out_chan_popupmenu));
else
    deviceConfig.loopback_in_chan = [];
    deviceConfig.loopback_out_chan = [];
end


save(handles.save_path, 'deviceConfig')
if ~isequal(handles.load_path, handles.save_path)
    save(handles.load_path, 'deviceConfig')
end
handles.output = deviceConfig.fs;
guidata(hObject, handles);
%close
uiresume(handles.figure1);


% --- Executes on selection change in in_device_id_popupmenu.
function in_device_id_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to in_device_id_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns in_device_id_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from in_device_id_popupmenu
update_view(hObject, handles)


% --- Executes during object creation, after setting all properties.
function in_device_id_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to in_device_id_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in out_device_id_popupmenu.
function out_device_id_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to out_device_id_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns out_device_id_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from out_device_id_popupmenu
update_view(hObject, handles)

% --- Executes during object creation, after setting all properties.
function out_device_id_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to out_device_id_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in audio_api_popupmenu.
function audio_api_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to audio_api_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns audio_api_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from audio_api_popupmenu

%update the list of device options, other ui elements will update is due course
populate_device_menus(hObject,handles)


% --- Executes during object creation, after setting all properties.
function audio_api_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to audio_api_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sample_rate_popupmenu.
function sample_rate_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to sample_rate_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sample_rate_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sample_rate_popupmenu


% --- Executes during object creation, after setting all properties.
function sample_rate_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sample_rate_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- fills in the list of available devices
function populate_device_menus(hObject,handles)
api_list = get(handles.audio_api_popupmenu,'string');
api = api_list{get(handles.audio_api_popupmenu,'value')};
[od, id, s] = get_playrec_devices_by_api(api);
handles.od = od;
handles.id = id;
handles.devices = s;
bool_array_input_device = ismember([s(:).deviceID],id);
bool_array_output_device = ismember([s(:).deviceID],od);
set(handles.in_device_id_popupmenu, 'String',{s(bool_array_input_device).name});
set(handles.out_device_id_popupmenu, 'String',{s(bool_array_output_device).name});
set(handles.in_device_id_popupmenu,'Value',1);
set(handles.out_device_id_popupmenu,'Value',1);

% pre-select saved value
if ~handles.is_initialised.devices
    if ~isempty(handles.savedDeviceConfig)
        if ~select_popupmenu_entry(handles.in_device_id_popupmenu,...
                                   get_saved_data(handles,'input_device_name'))
            warning('couldn''t restore input device - ignoring saved config')
            handles.savedConfig = [];
        end
    end
    if ~isempty(handles.savedDeviceConfig)
        if ~select_popupmenu_entry(handles.out_device_id_popupmenu,...
                                   get_saved_data(handles,'output_device_name'))
            warning('couldn''t restore output device - ignoring saved config')
            handles.savedConfig = [];
        end
    end
end
handles.is_initialised.devices = 1;

guidata(hObject, handles);
update_view(hObject, handles)

% --- fills in the selected device info
function update_view(hObject, handles)

%get selected items by value
i_in = get(handles.in_device_id_popupmenu, 'Value');
i_out = get(handles.out_device_id_popupmenu, 'Value');

%retrieve stored data
od = handles.od;
id = handles.id;
s = handles.devices;

%extract selected items
s_in = s([s.deviceID]==id(i_in));
s_out = s([s.deviceID]==od(i_out));

%fill in ui
set(handles.in_device_name_text, 'String',['Name: ',s_in.name])
set(handles.in_device_ins_text, 'String',['Inputs: ',num2str(s_in.inputChans)])
set(handles.in_device_outs_text, 'String',['Outputs: ',num2str(s_in.outputChans)])

set(handles.out_device_name_text, 'String',['Name: ',s_out.name])
set(handles.out_device_ins_text, 'String',['Inputs: ',num2str(s_out.inputChans)])
set(handles.out_device_outs_text, 'String',['Outputs: ',num2str(s_out.outputChans)])

handles.s_in = s_in;
handles.s_out = s_out;

guidata(hObject, handles);
populate_sample_rate_and_loopback_popupmenus(hObject, handles );




% --- fills in the list of available sample rates
function populate_sample_rate_and_loopback_popupmenus(hObject, handles)

%% sample rates
% try to retain the current value
if handles.is_initialised.device_settings
    current_sample_rate = str2double(get_popupmenu_selected_string(handles.sample_rate_popupmenu));
end

% no list of available sample rates so need to try each one in turn
sample_rates = test_playrec_available_sample_rates(handles.all_sample_rates,...
                                             handles.s_out.deviceID,...
                                             handles.s_in.deviceID);
set(handles.sample_rate_popupmenu,'String',cellstr(num2str(sort(sample_rates))));

% sequentially preselect popup menu using
% 1. fail safe
% 2. default
% 3. saved value
set(handles.sample_rate_popupmenu,'Value',1);

select_popupmenu_entry(handles.sample_rate_popupmenu,...
                       handles.default_sample_rate);

if handles.is_initialised.device_settings
    select_popupmenu_entry(handles.sample_rate_popupmenu,...
                           current_sample_rate);
elseif ~isempty(handles.savedDeviceConfig)
    if ~select_popupmenu_entry(handles.sample_rate_popupmenu,...
                               get_saved_data(handles,'sample_rate'))
        warning('couldn''t restore sample rate - ignoring saved config')
        handles.savedConfig = [];
    end
end



%% loopback menus
if ~isempty(handles.savedDeviceConfig)  && ~handles.is_initialised.device_settings
    set(handles.loopback_checkbox,'value',...
        get_saved_data(handles,'do_loopback'));
end 


    %get channel numbers for output and input devices and put into loopback
    %popupmenus
    
    %out
    max_chan = handles.s_out.outputChans;
    if max_chan > 0
        loop_out_list = {};
        for i= 1:max_chan
            loop_out_list(i) = num2cell(i);
        end
        current_value = str2double(get_popupmenu_selected_string(handles.loopback_out_chan_popupmenu));
        set(handles.loopback_out_chan_popupmenu, 'Value', 1);
        set(handles.loopback_out_chan_popupmenu, 'String', loop_out_list);
        set(handles.loopback_out_chan_popupmenu, 'Enable','on');
        % restore the previous value
        select_popupmenu_entry(handles.loopback_out_chan_popupmenu,...
                               current_value);
                          
        if ~isempty(handles.savedDeviceConfig) && ~handles.is_initialised.device_settings && handles.savedDeviceConfig.loopback
            if ~select_popupmenu_entry(handles.loopback_out_chan_popupmenu,...
                                   get_saved_data(handles,'loopback_out_chan'))           
                warning('couldn''t restore loopback_out_chan_popupmenu - ignoring saved config')
                handles.savedConfig = [];
            end
        end       
    else
        set(handles.loopback_out_chan_popupmenu, 'Enable','off');
    end

    %in
    max_chan = handles.s_in.inputChans;
    if max_chan > 0
        loop_in_list = {};
        for i= 1:max_chan
            loop_in_list(i) = num2cell(i);
        end
        current_value = str2double(get_popupmenu_selected_string(handles.loopback_in_chan_popupmenu));
        set(handles.loopback_in_chan_popupmenu, 'Value', 1);
        set(handles.loopback_in_chan_popupmenu, 'String', loop_in_list);
        set(handles.loopback_in_chan_popupmenu, 'Enable','on');
        % restore the previous value
        select_popupmenu_entry(handles.loopback_in_chan_popupmenu,...
                               current_value);
        if ~isempty(handles.savedDeviceConfig) && ~handles.is_initialised.device_settings && handles.savedDeviceConfig.loopback
            if ~select_popupmenu_entry(handles.loopback_in_chan_popupmenu,...
                                   get_saved_data(handles,'loopback_in_chan'))           
                warning('couldn''t restore loopback_in_chan_popupmenu - ignoring saved config')
                handles.savedConfig = [];
            end
        end
    else
        set(handles.loopback_in_chan_popupmenu, 'Enable','off');
    end


handles.is_initialised.device_settings = 1;

guidata(hObject, handles);                                    


% --- Executes on button press in loopback_checkbox.
function loopback_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to loopback_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loopback_checkbox


% --- Executes on selection change in loopback_out_chan_popupmenu.
function loopback_out_chan_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to loopback_out_chan_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns loopback_out_chan_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from loopback_out_chan_popupmenu


% --- Executes during object creation, after setting all properties.
function loopback_out_chan_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loopback_out_chan_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in loopback_in_chan_popupmenu.
function loopback_in_chan_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to loopback_in_chan_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns loopback_in_chan_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from loopback_in_chan_popupmenu


% --- Executes during object creation, after setting all properties.
function loopback_in_chan_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loopback_in_chan_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(handles.figure1)



function[retvalue] = get_saved_data(handles,param_name)
% provide a unified interface to extract data from the saved config
savedConfig = handles.savedDeviceConfig;

%% find the input/output devices
% get list of all device ids in the saved structure
saved_deviceIDs = [savedConfig.devices(:).deviceID];

device_index = find(savedConfig.inputDeviceID == saved_deviceIDs);
input_device = savedConfig.devices(device_index);

device_index = find(savedConfig.outputDeviceID == saved_deviceIDs);
output_device = savedConfig.devices(device_index);

switch param_name
    case 'audio_api'
        retvalue = unique({input_device.hostAPI,output_device.hostAPI});
        if numel(retvalue)~=1
            retvalue = nan;
        end
    case 'sample_rate'
        retvalue = savedConfig.fs;
    case 'input_device_name'
        retvalue = input_device.name;
    case 'output_device_name'
        retvalue = output_device.name;
    case 'do_loopback'
        retvalue = savedConfig.loopback;
    case 'loopback_out_chan'
        retvalue = savedConfig.loopback_out_chan;
    case 'loopback_in_chan'
        retvalue = savedConfig.loopback_in_chan;
    otherwise
        error('Unknown parameter')
end

function[selected_string] = get_popupmenu_selected_string(hObject)
contents = cellstr(get(hObject,'String'));
selected_string = contents{get(hObject,'Value')};

function[success] = select_popupmenu_entry(hObject,value)
success = 0;
menu_contents = get(hObject,'String');
if isnumeric(value)
    popup_index = find(value == str2double(menu_contents));
else
    popup_index = find(strcmp(value,menu_contents));
end
if numel(popup_index)==1
    set(hObject,'Value',popup_index);
    success = 1;
end

