function[fs] = setup()
%SETUP adds the necessary paths and runs some configuration utilities so
%that everything gets saved in the right place
%
%Alastair Moore, November 2006

addpath([pwd,'/m_files']);  %matlab needs to see all the functions called by hrtf_tool and getSysIR

%check playrec exists. If not prompt user to find it.
if ~check_for_playrec
    disp(sprintf('\n\tRequires playrec to run.'))
    disp(sprintf('\tPlease make sure you have a working version of playrec on your system and try again.'))
    return
end

fs = configureDevices()         %user selects the input and output devices
if fs==0
    error('configureDevices was closed without specifing devices and sample rate - rerun setup')
end
                            
setStimulusDirectory();     %user chooses where to save stimulus which are generated
                            %this avoids generating the same signal repeatedly                       