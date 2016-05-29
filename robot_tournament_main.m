%% Modify these configuartion parameters based on where the resources are located on your computer and your computer's parameters.

clc;
clear;
close all force;

% Modify these paths based on where the respective resources are located
home_path = '/Users/pranthiksamal/Documents/Berkeley/ReaderCourses/E7/e7-robot-tournament/';
submission_folder_path = '/Users/pranthiksamal/Documents/Berkeley/ReaderCourses/E7/e7-robot-tournament-submissions/Robot_Tournament_Main_Event-04-23/';
json_file_export_path = '/Users/pranthiksamal/Documents/Berkeley/ReaderCourses/E7/';

% Do not modify these string names and concatenation operations
json_file_name = 'e7_student_rankings.js';
json_file_export_path = [json_file_export_path json_file_name];

% Configuration parameters that depend on your OS
robot_tournament_config.directory_separator = '/';

% Tournament specific parameters
robot_tournament_config.show = false;
robot_tournament_config.speed = 5;
% Update this line to host the current battle function
robot_tournament_config.battle_func = @battle_v1;

% Load and set up the tournament maps.

load RoboMaps

% Isolation
robot_tournament_config.tournament_maps(1) = maps(1);
% Epitaph
%robot_tournament_config.tournament_maps(2) = maps(2);
% Narrows
%robot_tournament_config.tournament_maps(3) = maps(3);

%% Load the robots.

cd(home_path);

robot_array = bulk_to_robot_array( home_path, submission_folder_path, robot_tournament_config );

disp('Beginning tournament...\n');

robot_array = tournament_v2(robot_array, robot_tournament_config);

disp('The tournament is now complete\n');

%% Export the tournament results to a JSON file for upload to the website.

disp('Exporting tournament results to a JSON file for upload to the webpage\n');

% Sort the results from the tournament run
for I = 1:length(robot_array)
    insertion_index = I;
    for J = I:length(robot_array)
        if robot_array{J}.robot_struct.points >= robot_array{insertion_index}.robot_struct.points
            insertion_index = J;
        end
    end
    temp = robot_array{insertion_index};
    robot_array{insertion_index} = robot_array{I};
    robot_array{I} = temp;
end

% Assign a rank to each robot
for I = 1:length(robot_array)
    robot_array{I}.robot_struct.rank = I;
end

% Convert the robot array into a JSON array for uploading to the robot
% tournament webpage
robot_array_to_json(json_file_export_path, robot_array);

display(sprintf('You can find the JSON file in %s\n', json_file_export_path));
