function [ merged_robot_array ] = merge_robot_arrays( robot_array1, robot_array2 )
%merge_robot_arrays Merges two robot arrays by Team names
%   Takes in two robot arrays, accumulates all of their points by robot and
%   then re-ranks them.


merged_robot_array = {};

I = 1;
flag = 0;

while I <= length(robot_array1)
    J = 1;
    while J <= length(robot_array2)
        if wkStrCmp(robot_array1{I}.group_information.group_name, robot_array2{J}.group_information.group_name, 0.01)
            
            display(['Now merging information for: ' robot_array1{I}.group_information.group_name]);
            
            append_index = length(merged_robot_array) + 1;
            merged_robot_array{append_index} = robot_array1{I};
            merged_robot_array{append_index}.robot_struct.wins = robot_array1{I}.robot_struct.wins + robot_array2{J}.robot_struct.wins;
            merged_robot_array{append_index}.robot_struct.losses = robot_array1{I}.robot_struct.losses + robot_array2{J}.robot_struct.losses;
            merged_robot_array{append_index}.robot_struct.ties = robot_array1{I}.robot_struct.ties + robot_array2{J}.robot_struct.ties;
            merged_robot_array{append_index}.robot_struct.errors = robot_array1{I}.robot_struct.errors + robot_array2{J}.robot_struct.errors;
            merged_robot_array{append_index}.robot_struct.points = robot_array1{I}.robot_struct.points + robot_array2{J}.robot_struct.points;
            robot_array1(I) = [];
            robot_array2(J) = [];
            flag = 1;
            break;
        end
        J = J + 1;
    end
    if flag
        flag = 0;
    else
        I = I + 1;
    end
end

% Merge together any robots that were not common to the two arrays

% display(length(robot_array1));
% if ~isempty(robot_array1) 
%     display(robot_array1{1}.group_information.group_submitter);
%     display(robot_array1{1}.robot_struct);    
% end
% display(length(robot_array2));
% if ~isempty(robot_array2) 
%     display(robot_array2{1}.group_information.group_submitter);
%     display(robot_array2{1}.robot_struct);
% end

merged_robot_array = [merged_robot_array robot_array1 robot_array2];


% Sort the merged results
for I = 1:length(merged_robot_array)
    insertion_index = I;
    for J = I:length(merged_robot_array)
        if merged_robot_array{J}.robot_struct.points >= merged_robot_array{insertion_index}.robot_struct.points
            insertion_index = J;
        end
    end
    temp = merged_robot_array{insertion_index};
    merged_robot_array{insertion_index} = merged_robot_array{I};
    merged_robot_array{I} = temp;
end

% Rerank the merged robots
for I = 1:length(merged_robot_array)
    merged_robot_array{I}.robot_struct.rank = I;
end


end

