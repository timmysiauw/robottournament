function [ ] = robot_array_to_json( javascript_file_name, robot_array )
%robot_array_to_json Convert a robot into a JSON array
%   Take a robot array and convert it into a JSON array in a javascript
%   file specified by the javascript_file_name. This will then be uploaded
%   to the server to be displayed on the webpage.

fid = fopen(javascript_file_name, 'w+');

fprintf(fid, 'var rankedTeamArray = [\n');

for I = 1:length(robot_array)
    
    fprintf(fid, '\t{\n');
    
    fprintf(fid, '\t\t\"rank\": %d,\n', robot_array{I}.robot_struct.rank);
    fprintf(fid, '\t\t\"name\": \"%s\",\n', robot_array{I}.robot_struct.team);
    fprintf(fid, '\t\t\"points\": %d,\n', robot_array{I}.robot_struct.points);
    fprintf(fid, '\t\t\"wins\": %d,\n', robot_array{I}.robot_struct.wins);
    fprintf(fid, '\t\t\"losses\": %d,\n', robot_array{I}.robot_struct.losses);
    fprintf(fid, '\t\t\"ties\": %d,\n', robot_array{I}.robot_struct.ties);
    fprintf(fid, '\t\t\"errors\": %d\n', robot_array{I}.robot_struct.errors);
    
    if I == length(robot_array)
        fprintf(fid, '\t}\n');
    else
        fprintf(fid, '\t},\n');
    end
    
end

fprintf(fid, '];');

fclose(fid);


end

