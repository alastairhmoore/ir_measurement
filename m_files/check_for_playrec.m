function [ proceed ] = check_for_playrec( )
%CHECK_FOR_PLAYREC is an auxilliary function to make sure matlab can see
%the playrec mex file. If it can't it will prompt the user to find it and
%its location to the path.
proceed = 0;
while ~proceed
    try
        s = playrec('getDevices');
        
        proceed = 1;
    catch
        if strcmp(computer,'MACI64')
            bh = msgbox('In the next file select dialogue box, please select the folder where playrec is located.', 'Find playrec','modal');
            while isvalid(bh)
                pause(0.1)
            end
        end
        folder_name = uigetdir(pwd,'Please select the folder containting playrec mex file');
        if ~folder_name
            break;  %user cancelled, return zero
        else
            addpath(folder_name); %add to path and try again
        end
    end
end

