function [ ] = robot_array_to_text( file_name, robot_array )
%robot_array_to_text export robot struct results to a text file
%   Exports the scoring information along with the group information to a
%   text file.

fid = fopen(file_name, 'w+');

for I = 1:length(robot_array)
    
    fprintf(fid, 'Rank: %d\n', robot_array{I}.robot_struct.rank);
    fprintf(fid, 'Team Name: %s\n', robot_array{I}.robot_struct.team);
    fprintf(fid, 'Points: %d\n', robot_array{I}.robot_struct.points);
    fprintf(fid, 'Wins: %d\n', robot_array{I}.robot_struct.wins);
    fprintf(fid, 'Losses: %d\n', robot_array{I}.robot_struct.losses);
    fprintf(fid, 'Ties: %d\n', robot_array{I}.robot_struct.ties);
    fprintf(fid, 'Errors: %d\n', robot_array{I}.robot_struct.errors);
%     fprintf(fid, 'Group Members:');
%     
%     for J = 1:robot_array{I}.group_information.number_of_students
%         fprintf(fid, ' %s,%s; ', cell2mat(robot_array{I}.group_information.group_members{J}.last_name), cell2mat(robot_array{I}.group_information.group_members{J}.first_name));
%     end
    
    fprintf(fid, '\n\n');
    
end

fclose(fid);

end

