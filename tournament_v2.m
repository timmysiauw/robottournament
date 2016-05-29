function [ robot_array ] = tournament_v2( robot_array, robot_tournament_config )
%tournament Runs a tournament on an array of robots
%   This function takes in a robot array and runs a round robin tournament
%   against all of them.

number_of_games = 0;

for I = 1:length(robot_tournament_config.tournament_maps)
    for J = 1:length(robot_array)
        for K = 1:length(robot_array)
            if J ~= K
                
                number_of_games = number_of_games + 2;
                
                if mod(number_of_games, 10) == 0
                    display(sprintf('\n##### There have been %d / %d games played so far. #####\n', number_of_games, (nchoosek(length(robot_array), 2) * length(robot_tournament_config.tournament_maps) * 2)));
                end
                
                display(sprintf('Now starting game %d on map %s', number_of_games, robot_tournament_config.tournament_maps(I).name));
                display(sprintf('Now %s v. %s ', robot_array{J}.robot_struct.team, robot_array{K}.robot_struct.team));
                display(sprintf('Robot %s submitted by %s', robot_array{J}.robot_struct.team, robot_array{J}.group_information.group_submitter));
                display(sprintf('Robot %s submitted by %s\n', robot_array{K}.robot_struct.team, robot_array{K}.group_information.group_submitter))
                
                
                [winner_game, err_game, errstr_game] = robot_tournament_config.battle_func(robot_array{J}.robot_struct, robot_array{K}.robot_struct, robot_tournament_config.tournament_maps(I), robot_tournament_config.show, robot_tournament_config.speed);
                
                if err_game
                    
                    disp(errstr_game.message);
                end
                
                if err_game == 0
                    
                    if winner_game == 0
                        robot_array{J}.robot_struct.ties = robot_array{J}.robot_struct.ties + 1;
                        robot_array{K}.robot_struct.ties = robot_array{K}.robot_struct.ties + 1;
                    elseif winner_game == 1
                        robot_array{J}.robot_struct.wins = robot_array{J}.robot_struct.wins + 1;
                        robot_array{J}.robot_struct.points = robot_array{J}.robot_struct.points + 1;
                        
                        robot_array{K}.robot_struct.losses = robot_array{K}.robot_struct.losses + 1;
                    elseif winner_game == 2
                        robot_array{J}.robot_struct.losses = robot_array{J}.robot_struct.losses + 1;
                        
                        robot_array{K}.robot_struct.wins = robot_array{K}.robot_struct.wins + 1;
                        robot_array{K}.robot_struct.points = robot_array{K}.robot_struct.points + 1;
                    end
                    
                elseif err_game == 1
                    
                    robot_array{J}.robot_struct.errors = robot_array{J}.robot_struct.errors + 1;
                    robot_array{J}.robot_struct.points = robot_array{J}.robot_struct.points - 2;
                    robot_array{K}.robot_struct.pass = robot_array{K}.robot_struct.pass + 1;
                    
                elseif err_game == 2
                    
                    robot_array{K}.robot_struct.errors = robot_array{K}.robot_struct.errors + 1;
                    robot_array{K}.robot_struct.points = robot_array{K}.robot_struct.points - 2;
                    robot_array{J}.robot_struct.pass = robot_array{J}.robot_struct.pass + 1;
                    
                else
                    error('Unexpected output from battle function %d', err);
                end                
            end
        end
    end
end

end
