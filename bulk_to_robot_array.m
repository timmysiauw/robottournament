function [ robot_array ] = bulk_to_robot_array( home_path, grading_path, robot_tournament_config )
%bulk_to_robot_array Takes the bulk download folder and converts it to a
%submission array of robots.

robot_array = {};
folders = dir(grading_path);

disp(folders);
robot_count = 1;

disp(length(folders));

disp('Loading robots');
disp(grading_path);

for F = 1:length(folders);
    
    % Loop through all of the bulk download folders
    if folders(F).isdir && ~strcmp(folders(F).name, '.') && ~strcmp(folders(F).name, '..')
        
        submission_attachments_path = [grading_path robot_tournament_config.directory_separator folders(F).name robot_tournament_config.directory_separator 'Submission Attachment(s)'];
        
        disp(['Loading submission for: ' folders(F).name]);
        
        robot.submission_attachments_path = submission_attachments_path;
        
        % Check if the submissions attachments folder is a valid folder,
        % then change into its directory.
        if isdir(submission_attachments_path)
            
            cd(submission_attachments_path);
            
            [problem_with_submission, submission_error_message] = validate_submission();
            
            % If the submission direcory contains no .m file and .txt file
            % then we'll assume that the person did not submit anything and
            % someone else in their group did. If they have an .m file and
            % are missing the .txt file or vice versa, then there is a
            % serious problem with their submission and we will not grade
            % them.
            if problem_with_submission == false
                
                error_loading_text_file = false;
                loading_text_file_error_string = '';
                % Now try loading all of the information from the group.txt
                % file and store it into the group_information struct.
                try
                    
                    robot.group_information = load_group_information();
                    
                catch err
                    error_loading_text_file = true;
                    loading_text_file_error_string = err;
                    disp(err);
                    fid = fopen([grading_path 'invalid_group_text_files.txt'], 'a');
                    fprintf(fid, 'Student Submission: %s\n', folders(F).name);
                    fprintf(fid, 'Submission Path: %s\n', submission_attachments_path);
                    fprintf(fid, '\n\n');
                    fclose(fid);
                    % pause;
                end
                
                if error_loading_text_file == false
                    
                    % Check to make sure that the inforamtion loaded in the
                    % group.txt file makes sense.
                    [problem_with_group_text_file, text_file_error_message] = validate_group_text_file();
                    
                    % If the group.txt file does not contain information that
                    % does not logically make sense they should not be loaded
                    % into the contest.
                    if problem_with_group_text_file == false
                        
                        disp(robot.group_information);
                        
                        % Check to make sure the robot was not already
                        % submitted.
                        [error_already_submitted, already_submitted_error_string] = check_submission_status(robot.group_information, robot_array);
                        
                        % If someone in their group has already submitted a
                        % robot then we will not load the current student's
                        % submission into the robot tournament array.
                        if error_already_submitted == false
                            
                            % Load the group's robot
                            robot.function_handle = load_team_function_handle();
                            
                            robot_struct.team = robot.group_information.group_name;
                            robot_struct.color = rand(1,3);
                            robot_struct.fun = robot.function_handle;
                            robot_struct.error = 0;
                            robot_struct.input.pos = [];
                            robot_struct.input.fuel = [];
                            robot_struct.input.prev = [];
                            robot_struct.mov = [];
                            robot_struct.t = [];
                            robot_struct.wins = 0;
                            robot_struct.losses = 0;
                            robot_struct.ties = 0;
                            robot_struct.errors = 0;
                            robot_struct.points = 0;
                            robot_struct.pass = 0;
                            
                            robot.robot_struct = robot_struct;
                            robot.valid_submission = true;
                            
                            % Put the robot into the robot array.
                            robot_array{robot_count} = robot;
                            robot_count = robot_count + 1;
                            
                        else
                            disp(already_submitted_error_string);
                        end
                    else
                        disp(text_file_error_message);
                    end
                else
                    disp(loading_text_file_error_string);
                end
                
            else
                disp(submission_error_message);
            end
            cd(home_path);
        end
    end
end

% TODO:
% Once we load all the robots we can loop through them all and check if
% there are multilple submissions. If so we can take the submission that
% has the latest time stamp. If we do this then we can take out the
% check_submission_status function.

end

function [problem_with_submission, submission_error_message] = validate_submission()
% Checks the following conditions:
% 1. There is at least and only 1 *.m file
% 2. There is a group.txt file

problem_with_submission = false;
submission_error_message = '';

if isempty(dir_nonhidden('*.m')) && isempty(dir_nonhidden('*.txt'))
    problem_with_submission = true;
    submission_error_message = 'There are no .m files or .txt files in your directory. We are assuming one of your group members has submitted for you.';
    return;
end

if length(dir_nonhidden('*.m')) ~= 1
    problem_with_submission = true;
    submission_error_message = 'There needs to be at least and only one .m file in your submission.';
    return;
end

% Check that there is a group.txt file while ignoring case sensitivity when
% comparing file name.

text_files = dir_nonhidden('*.txt');
flag_found = 0;

for I = 1:length(text_files)
    if strcmpi(text_files(I).name, 'group.txt')
        flag_found = 1;
    end
end

if flag_found ~= 1
    problem_with_submission = true;
    submission_error_message = 'There needs to a group.txt file in your submission';
    return;
end

end

function [problem_with_group_text_file, text_file_error_message] = validate_group_text_file()
% Checks the following conditions:
% 1. Checks that the team name is a max of 20 characters.
% 2. Checks that the number on line 2 matches with the number of students
% 3. Checks that the comma separated student lines are formatted accordint to:
%       a. There is a first name
%       b. There is a last name
%       c. There is a SID that is a double
%       d. There is a lab number that is a member of the set of lab numbers

problem_with_group_text_file = false;
text_file_error_message = '';

end

function [error_already_submitted, already_submitted_error_string] = check_submission_status(group_information, robot_array)
% checks that the group information does not already exist in the
% robot_array

error_already_submitted = false;
already_submitted_error_string = '';

for J = 1:group_information.number_of_students
    [error_already_submitted, already_submitted_error_string] = already_submitted(group_information.group_members{J}, robot_array);
    if  error_already_submitted == true
        already_submitted_error_string = 'It seems that one of your group members already submitted';
        return
    end
end

    function [error_already_submitted, already_submitted_team] = already_submitted(group_member, robot_array)
        error_already_submitted = false;
        already_submitted_team = '';
        for K = 1:length(robot_array)
            for L = 1:robot_array{K}.group_information.number_of_students
                if group_member.SID == robot_array{K}.group_information.group_members{L}.SID
                    error_already_submitted = true;
                    already_submitted_team = robot_array{K}.group_information.group_name;
                    return
                end
            end
        end
    end
end

function [group_information] = load_group_information()

group_members = {};
fid = 0;

% Ignore case when loading the group.txt file. We now assume there is a
% group.txt text file already in the directory.

text_files = dir('*.txt');

for I = 1:length(text_files)
    if strcmpi(text_files(I).name, 'group.txt')
        fid = fopen(text_files(I).name);
    end
end

group_information.group_name = fgetl(fid);

group_information.number_of_students = str2double(fgetl(fid));

group_information.group_submitter = pwd;

for I = 1:group_information.number_of_students
    tline = fgetl(fid);
    split_line = regexp(tline, ',', 'split');
    student.last_name = split_line(1);
    student.first_name = split_line(2);
    student.SID = str2double(split_line(3));
    student.lab = str2double(split_line(4));
    
    group_members{I} = student;
end

fclose(fid);

group_information.group_members = group_members;

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
for I = 1:length(file_list)
    % In OS X and Ubuntu, hidden files start with a dot, who knows what
    % windows does.
    if ~file_list(I).isdir && ~strcmp(file_list(I).name(1), '.')
        unhidden_file_list = [unhidden_file_list file_list(I)];
    end
end

end