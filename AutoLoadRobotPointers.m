function [ autosaveRobotArray ] = AutoLoadRobotPointers( home_path, autosaveRobotArray )
%AutoLoadRobotPointers Reinitialize robot function pointers for AutoSave file
%   When saving an array function pointers are lost. This function will
%   reload the robot submission function pointers

for I = 1:length(autosaveRobotArray)
    
    cd(autosaveRobotArray{I}.submission_attachments_path);
    
    if autosaveRobotArray{I}.valid_submission == true;
        autosaveRobotArray{I}.function_handle = load_team_function_handle();
        autosaveRobotArray{I}.robot_struct.fun = load_team_function_handle();
    end
    
    cd(home_path);
end

    function [function_handle] = load_team_function_handle()
        
        % We have alredy made and checked the assumption that there is only one .m
        % file
        
        function_m_file = dir_nonhidden('*.m');
        
        function_m_file = function_m_file(1).name;
        
        function_handle = str2func(function_m_file(1:end-2));
        
    end

    function [unhidden_file_list] = dir_nonhidden(path)
        
        % Do a normal dir
        file_list = dir(path);
        unhidden_file_list = [];
        
        % Loop to identify hidden files
        for J = 1:length(file_list)
            % In OS X and Ubuntu, hidden files start with a dot, who knows what
            % windows does.
            if ~file_list(J).isdir && ~strcmp(file_list(J).name(1), '.')
                unhidden_file_list = [unhidden_file_list file_list(J)];
            end
        end
        
    end

end

