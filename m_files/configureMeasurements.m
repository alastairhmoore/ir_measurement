function varargout = configureMeasurements(varargin)
%CONFIGUREMEASUREMENTS M-file for configureMeasurements.fig
%      CONFIGUREMEASUREMENTS, by itself, creates a new CONFIGUREMEASUREMENTS or raises the existing
%      singleton*.
%
%      H = CONFIGUREMEASUREMENTS returns the handle to a new CONFIGUREMEASUREMENTS or the handle to
%      the existing singleton*.
%
%      CONFIGUREMEASUREMENTS('Property','Value',...) creates a new CONFIGUREMEASUREMENTS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to configureMeasurements_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CONFIGUREMEASUREMENTS('CALLBACK') and CONFIGUREMEASUREMENTS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CONFIGUREMEASUREMENTS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help configureMeasurements

% Last Modified by GUIDE v2.5 09-Nov-2006 14:41:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @configureMeasurements_OpeningFcn, ...
                   'gui_OutputFcn',  @configureMeasurements_OutputFcn, ...
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


% --- Executes just before configureMeasurements is made visible.
function configureMeasurements_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for configureMeasurements
%handles.output = hObject;
handles.output = 0;

% Update handles structure
guidata(hObject, handles);

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')


%get the current device configurations
handles.deviceConfig = getAudioDeviceIOSettings();

%fill available channel info into the relevant popdown menus
%we are simply passing the number of ouput and input channels available
fillChannelInfo(handles);


% set the paths to required files
parent_dir = fileparts(mfilename());
handles.available_signals_file = fullfile(parent_dir,'availableSignals.mat');
handles.measurement_config_file = fullfile(parent_dir,'MeasurementConfig.mat');


% get the available signals
if exist(handles.available_signals_file, 'file')
    load(handles.available_signals_file,'availableSignals');
else
    error('No signal data available')
end
handles.availableSignals = availableSignals;

%fill available signal info into the relevant popdown menus
fillSignalInfo(handles)

%fill in the option parameters and labels using 1st available signal
updateHRTFSignalParameters(handles.availableSignals(1).nOptions,...
    handles.availableSignals(1).optionNames,...
    handles.availableSignals(1).optionDefaults, handles);
updatePhonesSignalParameters(handles.availableSignals(1).nOptions,...
    handles.availableSignals(1).optionNames,...
    handles.availableSignals(1).optionDefaults, handles);


%at this point there is valid data in all parts of the gui

%check for MeasurmentConfig.mat - doesn't matter if it's not
%if there read it in 
if exist(handles.measurement_config_file,'file')
    load(handles.measurement_config_file,'measurementConfig')
    handles.measurementConfig = measurementConfig;
    
    %set sampling frequency
    set(handles.Fs_textbox,'String', num2str(measurementConfig.Fs));

    %check that the availble channels is enough to meet the requirements
    %then set values of inputs, hrtf out and phones outs
    if max(measurementConfig.recChan) <= length(get(handles.left_in_popupmenu, 'String'))
        set(handles.left_in_popupmenu, 'Value', measurementConfig.recChan(1));
        set(handles.right_in_popupmenu, 'Value', measurementConfig.recChan(2));
    end
    if measurementConfig.hrtfPlayChan <= length(get(handles.hrtf_out_chan_popupmenu, 'String'))
        set(handles.hrtf_out_chan_popupmenu, 'Value', measurementConfig.hrtfPlayChan);
    end
    if max(measurementConfig.phonesPlayChan) <= length(get(handles.phones_left_chan_popupmenu, 'String'))
        set(handles.phones_left_chan_popupmenu, 'Value', measurementConfig.phonesPlayChan(1));
        set(handles.phones_right_chan_popupmenu, 'Value', measurementConfig.phonesPlayChan(2));
    end
    
    %look for the saved signals in available signals
    i = 1;
    hrtf_match = 0;
    phones_match = 0;
    while ((hrtf_match == 0) || (phones_match == 0)) && i-1 < length(handles.availableSignals)
        
        if isequal(measurementConfig.hrtfFunctionHandle,handles.availableSignals(i).functionHandle)
            hrtf_match = 1;
            i_hrtf = i;
        end
        
        if isequal(measurementConfig.phonesFunctionHandle,handles.availableSignals(i).functionHandle)
            phones_match = 1;
            i_phones = i;
        end
        i=i+1;
    end
    
    %set signals to saved value
    if hrtf_match
        set(handles.hrtf_signal_popupmenu,'Value',i_hrtf);
    end
    if phones_match
        set(handles.phones_signal_popupmenu,'Value',i_phones);
    end
    
    %set signal parameters to saved values
    updateHRTFSignalParameters(handles.availableSignals(i_hrtf).nOptions,...
        handles.availableSignals(i_hrtf).optionNames,...
        handles.measurementConfig.hrtfOptions, handles);
    updatePhonesSignalParameters(handles.availableSignals(i_phones).nOptions,...
        handles.availableSignals(i_phones).optionNames,...
        handles.measurementConfig.phonesOptions, handles);
        
        
        
    
       
    
    %check whether the signals specified in MeasurementConfig.mat are available
    %if so choose them and fill the options into the boxes
end







% Update handles structure
guidata(hObject, handles);

% UIWAIT makes configureMeasurements wait for user response (see UIRESUME)
uiwait(handles.figure1);







 
 

% --- Outputs from this function are returned to the command line.
function varargout = configureMeasurements_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);



% --- Executes when user attempts to close figure1.
function closereq(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('called CloseRequestFcn')
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    %delete(handles.figure1);
end



% --- Executes on selection change in left_in_popupmenu.
function left_in_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to left_in_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns left_in_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from left_in_popupmenu


% --- Executes during object creation, after setting all properties.
function left_in_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to left_in_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in right_in_popupmenu.
function right_in_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to right_in_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns right_in_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from right_in_popupmenu


% --- Executes during object creation, after setting all properties.
function right_in_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to right_in_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hrtf_out_chan_popupmenu.
function hrtf_out_chan_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to hrtf_out_chan_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns hrtf_out_chan_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hrtf_out_chan_popupmenu


% --- Executes during object creation, after setting all properties.
function hrtf_out_chan_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hrtf_out_chan_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hrtf_signal_popupmenu.
function hrtf_signal_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to hrtf_signal_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns hrtf_signal_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hrtf_signal_popupmenu
i = get(hObject, 'Value');
updateHRTFSignalParameters(handles.availableSignals(i).nOptions,...
    handles.availableSignals(i).optionNames,...
    handles.availableSignals(i).optionDefaults, handles);

% --- Executes during object creation, after setting all properties.
function hrtf_signal_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hrtf_signal_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hrtf_1_Callback(hObject, eventdata, handles)
% hObject    handle to hrtf_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hrtf_1 as text
%        str2double(get(hObject,'String')) returns contents of hrtf_1 as a double


% --- Executes during object creation, after setting all properties.
function hrtf_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hrtf_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hrtf_2_Callback(hObject, eventdata, handles)
% hObject    handle to hrtf_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hrtf_2 as text
%        str2double(get(hObject,'String')) returns contents of hrtf_2 as a double


% --- Executes during object creation, after setting all properties.
function hrtf_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hrtf_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hrtf_3_Callback(hObject, eventdata, handles)
% hObject    handle to hrtf_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hrtf_3 as text
%        str2double(get(hObject,'String')) returns contents of hrtf_3 as a double


% --- Executes during object creation, after setting all properties.
function hrtf_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hrtf_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hrtf_4_Callback(hObject, eventdata, handles)
% hObject    handle to hrtf_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hrtf_4 as text
%        str2double(get(hObject,'String')) returns contents of hrtf_4 as a double


% --- Executes during object creation, after setting all properties.
function hrtf_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hrtf_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hrtf_5_Callback(hObject, eventdata, handles)
% hObject    handle to hrtf_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hrtf_5 as text
%        str2double(get(hObject,'String')) returns contents of hrtf_5 as a double


% --- Executes during object creation, after setting all properties.
function hrtf_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hrtf_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in phones_left_chan_popupmenu.
function phones_left_chan_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to phones_left_chan_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns phones_left_chan_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from phones_left_chan_popupmenu


% --- Executes during object creation, after setting all properties.
function phones_left_chan_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phones_left_chan_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in phones_signal_popupmenu.
function phones_signal_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to phones_signal_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns phones_signal_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from phones_signal_popupmenu
i = get(hObject, 'Value');
updatePhonesSignalParameters(handles.availableSignals(i).nOptions,...
    handles.availableSignals(i).optionNames,...
    handles.availableSignals(i).optionDefaults, handles);


% --- Executes during object creation, after setting all properties.
function phones_signal_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phones_signal_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function phones_1_Callback(hObject, eventdata, handles)
% hObject    handle to phones_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phones_1 as text
%        str2double(get(hObject,'String')) returns contents of phones_1 as a double


% --- Executes during object creation, after setting all properties.
function phones_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phones_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function phones_2_Callback(hObject, eventdata, handles)
% hObject    handle to phones_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phones_2 as text
%        str2double(get(hObject,'String')) returns contents of phones_2 as a double


% --- Executes during object creation, after setting all properties.
function phones_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phones_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function phones_3_Callback(hObject, eventdata, handles)
% hObject    handle to phones_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phones_3 as text
%        str2double(get(hObject,'String')) returns contents of phones_3 as a double


% --- Executes during object creation, after setting all properties.
function phones_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phones_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function phones_4_Callback(hObject, eventdata, handles)
% hObject    handle to phones_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phones_4 as text
%        str2double(get(hObject,'String')) returns contents of phones_4 as a double


% --- Executes during object creation, after setting all properties.
function phones_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phones_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function phones_5_Callback(hObject, eventdata, handles)
% hObject    handle to phones_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phones_5 as text
%        str2double(get(hObject,'String')) returns contents of phones_5 as a double


% --- Executes during object creation, after setting all properties.
function phones_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phones_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in phones_right_chan_popupmenu.
function phones_right_chan_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to phones_right_chan_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns phones_right_chan_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from phones_right_chan_popupmenu


% --- Executes during object creation, after setting all properties.
function phones_right_chan_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phones_right_chan_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get all the data
measurementConfig.Fs = str2num(get(handles.Fs_textbox, 'String'));
measurementConfig.recChan = [get(handles.left_in_popupmenu, 'Value'),...
    get(handles.right_in_popupmenu, 'Value')];
%HRTF
measurementConfig.hrtfPlayChan = get(handles.hrtf_out_chan_popupmenu, 'Value');
hrtf_index = get(handles.hrtf_signal_popupmenu, 'Value');
measurementConfig.hrtfFunctionHandle = handles.availableSignals(hrtf_index).functionHandle;
measurementConfig.hrtfOptions = getHRTFOptionsData(handles);    %this takes data directly from boxes and returns cell array
%PHONES
measurementConfig.phonesPlayChan = [get(handles.phones_left_chan_popupmenu, 'Value'),...
    get(handles.phones_right_chan_popupmenu, 'Value')];
phones_index = get(handles.phones_signal_popupmenu, 'Value');
measurementConfig.phonesFunctionHandle = handles.availableSignals(phones_index).functionHandle;
measurementConfig.phonesOptions = getPhonesOptionsData(handles);    %this takes data directly from boxes and returns cell array
    
save(handles.measurement_config_file, 'measurementConfig');


handles.output = measurementConfig;
guidata(hObject,handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


function Fs_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to Fs_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Fs_textbox as text
%        str2double(get(hObject,'String')) returns contents of Fs_textbox as a double


% --- Executes during object creation, after setting all properties.
function Fs_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fs_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.errMsg = 'Window cancelled';
    
    % Update handles structure
    guidata(hObject, handles);
    %continue to exit
    uiresume(handles.figure1);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    %Enter is equivalent to pressing save button, so call that functions
    save_button_Callback(handles.save_button,eventdata,handles)
end    


function fillChannelInfo(handles)
%get the number of ins and outs
% - looks a bit involved
% - +1 indexing is becasue ID's start at zero
ins = handles.deviceConfig.devices(handles.deviceConfig.inputDeviceID + 1).inputChans;
outs = handles.deviceConfig.devices(handles.deviceConfig.outputDeviceID +1).outputChans;
%create cell array of output channel numbers
for n = 1:outs
    chans(n) = {num2str(n)};
end
%put array into popup menus
set(handles.hrtf_out_chan_popupmenu, 'String', chans);
set(handles.phones_left_chan_popupmenu, 'String', chans);
set(handles.phones_right_chan_popupmenu, 'String', chans);

%create cell array of input channel numbers
for n = 1:ins
    chans(n) = {num2str(n)};
end
%put array into popup menus
set(handles.left_in_popupmenu, 'String', chans);
set(handles.right_in_popupmenu, 'String', chans);

function fillSignalInfo(handles)
set(handles.hrtf_signal_popupmenu, 'String', {handles.availableSignals.signalName});
set(handles.phones_signal_popupmenu, 'String', {handles.availableSignals.signalName});


function updateHRTFSignalParameters(nLabels,Names,Values,handles)
%this is inefficient but can't find a better way of doing it
%Label 1
if nLabels > 0
    set(handles.hrtf_option1_label, 'String', Names(1));
    set(handles.hrtf_option1_label, 'Visible', 'on');
    set(handles.hrtf_1, 'String', cell2mat(Values(1)));
    set(handles.hrtf_1, 'Visible','on');
else
    set(handles.hrtf_option1_label, 'Visible', 'off');
    set(handles.hrtf_1, 'Visible','off');
end
%Label 2
if nLabels > 1
    set(handles.hrtf_option2_label, 'String', Names(2));
    set(handles.hrtf_option2_label, 'Visible', 'on');
    set(handles.hrtf_2, 'String', cell2mat(Values(2)));
    set(handles.hrtf_2, 'Visible','on');
else
    set(handles.hrtf_option2_label, 'Visible', 'off');
    set(handles.hrtf_2, 'Visible','off');
end   
%Label 3
if nLabels > 2
    set(handles.hrtf_option3_label, 'String', Names(3));
    set(handles.hrtf_option3_label, 'Visible', 'on');
    set(handles.hrtf_3, 'String', cell2mat(Values(3)));
    set(handles.hrtf_3, 'Visible','on');
else
    set(handles.hrtf_option3_label, 'Visible', 'off');
    set(handles.hrtf_3, 'Visible','off');
end
%Label 4
if nLabels > 3
    set(handles.hrtf_option4_label, 'String', Names(4));
    set(handles.hrtf_option4_label, 'Visible', 'on');
    set(handles.hrtf_4, 'String', cell2mat(Values(4)));
    set(handles.hrtf_4, 'Visible','on');
else
    set(handles.hrtf_option4_label, 'Visible', 'off');
    set(handles.hrtf_4, 'Visible','off');
end
%Label 5
if nLabels > 4
    set(handles.hrtf_option5_label, 'String', Names(5));
    set(handles.hrtf_option5_label, 'Visible', 'on');
    set(handles.hrtf_5, 'String', cell2mat(Values(5)));
    set(handles.hrtf_5, 'Visible','on');
else
    set(handles.hrtf_option5_label, 'Visible', 'off');
    set(handles.hrtf_5, 'Visible','off');
end


function updatePhonesSignalParameters(nLabels,Names,Values,handles)

%this is inefficient but can't find a better way of doing it
%Label 1
if nLabels > 0
    set(handles.phones_option1_label, 'String', Names(1));
    set(handles.phones_option1_label, 'Visible', 'on');
    set(handles.phones_1, 'String', cell2mat(Values(1)));
    set(handles.phones_1, 'Visible','on');
else
    set(handles.phones_option1_label, 'Visible', 'off');
    set(handles.phones_1, 'Visible','off');
end
%Label 2
if nLabels > 1
    set(handles.phones_option2_label, 'String', Names(2));
    set(handles.phones_option2_label, 'Visible', 'on');
    set(handles.phones_2, 'String', cell2mat(Values(2)));
    set(handles.phones_2, 'Visible','on');
else
    set(handles.phones_option2_label, 'Visible', 'off');
    set(handles.phones_2, 'Visible','off');
end   
%Label 3
if nLabels > 2
    set(handles.phones_option3_label, 'String', Names(3));
    set(handles.phones_option3_label, 'Visible', 'on');
    set(handles.phones_3, 'String', cell2mat(Values(3)));
    set(handles.phones_3, 'Visible','on');
else
    set(handles.phones_option3_label, 'Visible', 'off');
    set(handles.phones_3, 'Visible','off');
end
%Label 4
if nLabels > 3
    set(handles.phones_option4_label, 'String', Names(4));
    set(handles.phones_option4_label, 'Visible', 'on');
    set(handles.phones_4, 'String', cell2mat(Values(4)));
    set(handles.phones_4, 'Visible','on');
else
    set(handles.phones_option4_label, 'Visible', 'off');
    set(handles.phones_4, 'Visible','off');
end
%Label 5
if nLabels > 4
    set(handles.phones_option5_label, 'String', Names(5));
    set(handles.phones_option5_label, 'Visible', 'on');
    set(handles.phones_5, 'String', cell2mat(Values(5)));
    set(handles.phones_5, 'Visible','on');
else
    set(handles.phones_option5_label, 'Visible', 'off');
    set(handles.phones_5, 'Visible','off');
end


function[options] = getHRTFOptionsData(handles);
i = get(handles.hrtf_signal_popupmenu, 'Value');
n = handles.availableSignals(i).nOptions;
options = {};
if n > 0
    options(1) = {str2num(get(handles.hrtf_1, 'String'))};
end
if n > 1
    options(2) = {str2num(get(handles.hrtf_2, 'String'))};
end
if n > 2
    options(3) = {str2num(get(handles.hrtf_3, 'String'))};
end
if n > 3
    options(4) = {str2num(get(handles.hrtf_4, 'String'))};
end
if n > 4
    options(5) = {str2num(get(handles.hrtf_5, 'String'))};
end

function[options] = getPhonesOptionsData(handles);
i = get(handles.phones_signal_popupmenu, 'Value');
n = handles.availableSignals(i).nOptions;
options = {};
if n > 0
    options(1) = {str2num(get(handles.phones_1, 'String'))};
end
if n > 1
    options(2) = {str2num(get(handles.phones_2, 'String'))};
end
if n > 2
    options(3) = {str2num(get(handles.phones_3, 'String'))};
end
if n > 3
    options(4) = {str2num(get(handles.phones_4, 'String'))};
end
if n > 4
    options(5) = {str2num(get(handles.phones_5, 'String'))};
end