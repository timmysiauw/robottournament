for I = 1:length(robot_array)
   if strcmp( robot_array{I}.group_information.group_name, 'The Cult of Pulpo' );
       disp(robot_array{I}.group_information.group_submitter);
   end
end