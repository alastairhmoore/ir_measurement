function[stimulus_path] = setStimulusDirectory()
%SETSTIMULUSDIRECTORY uses a built in gui to select the folder where
%stimulus signals should be stored and saves it in stimulus_directory.mat

if ~exist('getSysIR.m', 'file')
    error('setStimulusDirectory must be called from the same directory as getSysIR.m')
end

if ~exist('m_files','dir')
    error('setStimulusDirectory: The folder "m_files" is missing')
end

if strcmp(computer,'MACI64')
    bh = msgbox('In the next file select dialogue box, please select the folder in which stimulus signals should be stored.', 'Stimulus directory');
    while isvalid(bh)
        pause(0.1)
    end
end
desired_path = 0;
while desired_path == 0
    desired_path = uigetdir(pwd,'Choose folder for storing stimulus signals...');
end
stimulus_path = [desired_path,'/'];

save m_files/stimulus_path.mat stimulus_path