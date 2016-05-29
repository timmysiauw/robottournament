function [ robot_array ] = tournament( robot_array, robot_tournament_config, match_record )
%tournament Runs a tournament on an array of robots
%   This function takes in a robot array and runs a round robin tournament
%   against all of them.

number_of_games = 0;

for I = 1:length(robot_tournament_config.tournament_maps)
    for J = 1:length(robot_array)
        for K = J:length(robot_array)
            if J ~= K
                
                number_of_games = number_of_games + 2;
                
                if mod(number_of_games, 10) == 0
                    display(sprintf('\n##### There have been %d / %d games played so far. #####\n', number_of_games, (nchoosek(length(robot_array), 2) * length(robot_tournament_config.tournament_maps) * 2)));
                end
                
                display(sprintf('Now starting game %d on map %s', number_of_games, robot_tournament_config.tournament_maps(I).name));
                display(sprintf('Now %s v. %s ', robot_array{J}.robot_struct.team, robot_array{K}.robot_struct.team));
                display(sprintf('Robot %s submitted by %s', robot_array{J}.robot_struct.team, robot_array{J}.group_information.group_submitter));
                display(sprintf('Robot %s submitted by %s\n', robot_array{K}.robot_struct.team, robot_array{K}.group_information.group_submitter));
                
                flag = false;
                
                for Q = 1:length(match_record)
                    if wkStrCmp([num2str(I) '-' robot_array{J}.group_information.group_name 'V' robot_array{K}.group_information.group_name], match_record{Q}, 0.01)
                        flag = true;
                        break;
                    end
                end
                
                if flag
                    display(sprintf('Match between %s v. %s has already been played.\n', robot_array{J}.robot_struct.team, robot_array{K}.robot_struct.team));
                    continue;
                end
                
                try
                    robot1.team = robot_array{J}.robot_struct.team;
                    robot1.color = robot_array{J}.robot_struct.color;
                    robot1.fun = robot_array{J}.robot_struct.fun;
                    robot1.error = robot_array{J}.robot_struct.error;
                    robot1.input.pos = robot_array{J}.robot_struct.input.pos;
                    robot1.input.fuel = robot_array{J}.robot_struct.input.fuel;
                    robot1.input.prev = robot_array{J}.robot_struct.input.prev;
                    robot1.mov = robot_array{J}.robot_struct.mov;
                    robot1.t = robot_array{J}.robot_struct.t;
                    robot1.wins = robot_array{J}.robot_struct.wins;
                    robot1.losses = robot_array{J}.robot_struct.losses;
                    robot1.ties = robot_array{J}.robot_struct.ties;
                    robot1.errors = robot_array{J}.robot_struct.errors;
                    robot1.points = robot_array{J}.robot_struct.points;
                    
                    robot2.team = robot_array{K}.robot_struct.team;
                    robot2.color = robot_array{K}.robot_struct.color;
                    robot2.fun = robot_array{K}.robot_struct.fun;
                    robot2.error = robot_array{K}.robot_struct.error;
                    robot2.input.pos = robot_array{K}.robot_struct.input.pos;
                    robot2.input.fuel = robot_array{K}.robot_struct.input.fuel;
                    robot2.input.prev = robot_array{K}.robot_struct.input.prev;
                    robot2.mov = robot_array{K}.robot_struct.mov;
                    robot2.t = robot_array{K}.robot_struct.t;
                    robot2.wins = robot_array{K}.robot_struct.wins;
                    robot2.losses = robot_array{K}.robot_struct.losses;
                    robot2.ties = robot_array{K}.robot_struct.ties;
                    robot2.errors = robot_array{K}.robot_struct.errors;
                    robot2.points = robot_array{K}.robot_struct.points;
                    
                    
                    [winner_game1, err_game1, errstr_game1] = robot_tournament_config.battle_func(robot1, robot2, robot_tournament_config.tournament_maps(I), robot_tournament_config.show, robot_tournament_config.speed);
                    
                    if err_game1
                        
                        disp(errstr_game1.message);
                    end
                    
                    if err_game1 == 0
                        
                        if winner_game1 == 0
                            robot1.ties = robot1.ties + 1;
                            robot2.ties = robot2.ties + 1;
                        elseif winner_game1 == 1
                            robot1.wins = robot1.wins + 1;
                            robot1.points = robot1.points + 1;
                            
                            robot2.losses = robot2.losses + 1;
                        elseif winner_game1 == 2
                            robot1.losses = robot1.losses + 1;
                            
                            robot2.wins = robot2.wins + 1;
                            robot2.points = robot2.points + 1;
                        end
                        
                    elseif err_game1 == 1
                        
                        robot1.errors = robot1.errors + 1;
                        robot1.points = robot1.points - 2;
                        
                    elseif err_game1 == 2
                        
                        robot2.errors = robot2.errors + 1;
                        robot2.points = robot2.points - 2;
                        
                    else
                        error('Unexpected output from battle function %d', err);
                    end
                    
                    [winner_game2, err_game2, errstr_game2] = robot_tournament_config.battle_func(robot2, robot1, robot_tournament_config.tournament_maps(I), robot_tournament_config.show, robot_tournament_config.speed);
                    
                    if err_game2
                        
                        disp(errstr_game2.message);
                    end
                    
                    if err_game2 == 0
                        
                        if winner_game2 == 0
                            
                            robot1.ties = robot1.ties + 1;
                            robot2.ties = robot2.ties + 1;
                        elseif winner_game2 == 1
                            
                            robot1.losses = robot1.losses + 1;
                            
                            robot2.wins = robot2.wins + 1;
                            robot2.points = robot2.points + 1;
                        elseif winner_game2 == 2
                            
                            robot1.wins = robot1.wins + 1;
                            robot1.points = robot1.points + 1;
                            
                            robot2.losses = robot2.losses + 1;
                        end
                        
                    elseif err_game2 == 1
                        
                        robot2.errors = robot2.errors + 1;
                        robot2.points = robot2.points - 2;
                        
                    elseif err_game2 == 2
                        
                        robot1.errors = robot1.errors + 1;
                        robot1.points = robot1.points - 2;
                        
                    else
                        error('Unexpected output from battle function %d', err);
                    end
                    
                    % Store the robot states
                    robot_array{J}.robot_struct = robot1;
                    robot_array{K}.robot_struct = robot2;
                    
                    match_record{length(match_record) + 1} = [num2str(I) '-' robot_array{J}.group_information.group_name 'V' robot_array{K}.group_information.group_name];
                    save('AutoSave-RobotTournament', 'robot_array', 'match_record');
                    
                catch err
                    display(err);
                    display('Exception thrown during match. Marking the two players as having tied and saving current results. Please restart the tournament.')
                    robot1.ties = robot1.ties + 1;
                    robot2.ties = robot2.ties + 1;
                    robot_array{J}.robot_struct = robot1;
                    robot_array{K}.robot_struct = robot2;
                    match_record{length(match_record) + 1} = [num2str(I) '-' robot_array{J}.group_information.group_name 'V' robot_array{K}.group_information.group_name];
                    delete('AutoSave*');
                    save('AutoSave-RobotTournament', 'robot_array', 'match_record');
                end
            end
        end
    end
end

end
