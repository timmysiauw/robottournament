function [ out ] = check_text_file( )
%check_text_file Checks E7 robot tournament group.txt file
%   Students should put this function in the same directory as their
%   group.txt file and their robot. The function will run and check that
%   all the deliverables are in place and properly formatted.

out = 0;

if length(dir_nonhidden('group.txt')) ~= 1
    disp(['Cannot locate your group.txt file. This is a case sensistive check i.e. if you named your file /"Group.txt/" with the /"g/" in group capitalized, then we will not look at your file. Also please make sure the file is in this current directory: ' pwd]);
    return;
end

try
    
    group_members = {};
    
    fid = fopen('group.txt');
    
    group_information.group_name = fgetl(fid);
    
    group_information.number_of_students = str2double(fgetl(fid));
    
    for I = 1:group_information.number_of_students
        tline = fgetl(fid);
        split_line = regexp(tline, ',', 'split');
        student.last_name = split_line(1);
        student.first_name = split_line(2);
        student.SID = str2double(split_line(3));
        student.lab = str2double(split_line(4));
        
        group_members{I} = student;
        
        if isnan(student.SID) || isnan(student.lab) || ~isa(student.SID, 'double') || ~isa(student.lab, 'double')
            disp('Did you correctly format the SID of each student and their lab number?');
            out = 0;
            fclose(fid);
            return;
        end
    end
    
    fclose(fid);
    
    group_information.group_members = group_members;
    
    if length(group_information.group_name) > 20
        
        disp('Your team name is greater than 20 characters. Pleaese shorten it.');
        out = 0;
        return;
        
    else
        
        out = 1;
        return;
    end
    
catch err
    disp('An error occured when reading the group.txt file. Please make sure the inside of your file is correctly formatted by opening it in Notepad if you are running Windows, Textedit/Textmate if you are on Mac, and gedit if you are in Linux. If you open it and it does not look right, well that is the problem.');
    out = 0;
end

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
