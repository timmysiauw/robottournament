function [map] = get_map(map_opt)

params = get_params(0,0);

if isa(map_opt, 'char')

% first get a map without the players
switch map_opt
    
    case 'easy'
        
        map = create_easy();
        
    case 'sym'
        
        map = create_symrand(params, 4+ceil(rand*4), 8+ceil(rand*8), 10, 1000);
        
    case 'asym'
        
        map = create_asymrand(params, 10+ceil(rand*4), 20+ceil(rand*8), 10, 1000);
        
    otherwise
        
        error('Unrecognized map name: %s', map_opt)
        
end

elseif isa(map_opt, 'struct')
    
    map = map_opt;
    
end

% add the players to the map
map.robot = [];

    function [map] = create_easy()
        
        map.name = 'Easy';
        map.turn = 0;
        
        map.robot = [];
        
        map.tank(1).pos = [50 50];
        map.tank(1).val = 200;
        map.tank(2).pos = [50 75];
        map.tank(2).val = 200;
        map.tank(3).pos = [50 25];
        map.tank(3).val = 200;
        map.tank(4).pos = [90 90];
        map.tank(4).val = 200;
        map.tank(5).pos = [10 10];
        map.tank(5).val = 200;
        map.tank(6).pos = [10 90];
        map.tank(6).val = 200;
        map.tank(7).pos = [90 10];
        map.tank(7).val = 200;
        map.tank(8).pos = [10 50];
        map.tank(8).val = 200;
        map.tank(9).pos = [90 50];
        map.tank(9).val = 200;
        
        map.mine(1).pos = [25 25];
        map.mine(1).val = 50;
        map.mine(2).pos = [25 75];
        map.mine(2).val = 50;
        map.mine(3).pos = [75 75];
        map.mine(3).val = 50;
        map.mine(4).pos = [75 25];
        map.mine(4).val = 50;
        
        map.start(1).pos = [25 50];
        map.start(2).pos = [75 50];
        
    end % end create_easy

    function [map] = create_symrand(params, nTanks, nMines, cutDist, maxIter)
        % creates symrand map
        
        % define map name and initialize robot field
        map.name = 'SymRand';
        map.turn = 0;
        map.robot = [];
        
        % extract map dimensions (modify x_max to only include to only include half
        % of the map)
        x_max = params.game.x_min + (params.game.x_max-params.game.x_min)/2 - cutDist/2;
        x_min = params.game.x_min;
        y_max = params.game.y_max;
        y_min = params.game.y_min;
        
        % initialize iteration counter
        iter = 0;
        
        % initialize number of tanks and tank struct
        tanks = 0;
        tank = [];
        while tanks <= nTanks
            
            % get a new point candidate
            new_x = round(rand*(x_max-x_min)) + x_min;
            new_y = round(rand*(y_max-y_min)) + y_min;
            
            % check if this point is invalid
            invalid = 0;
            for i = 1:length(tank)
                % invalid if this point is too close to previously generated tanks
                if norm([new_x, new_y] - tank(i).pos,2) <= cutDist
                    invalid = 1;
                end
            end
            
            % if this point is good, add to tank struct and increment counter
            if ~invalid
                tank(length(tank)+1).pos = [new_x, new_y];
                tank(length(tank)).val = 50*ceil(rand*6);
                tanks = tanks + 1;
            end
            
            % update iteration counter, if exceeded max iterations allowed, just
            % return what we have.
            iter = iter + 1;
            if iter >= maxIter
                break
            end
            
        end % end
        
        % initialize mine counter and mine struct
        mines = 0;
        mine = [];
        while mines <= nMines
            
            % get new point for mine
            new_x = round(rand*(x_max-x_min) + x_min);
            new_y = round(rand*(y_max-y_min) + y_min);
            
            % check if new point is valid
            invalid = 0;
            for i = 1:length(mine)
                if norm([new_x, new_y] - mine(i).pos,2) <= cutDist
                    invalid = 1;
                end
            end
            
            % check if new point is valid relative to tanks also
            for i = 1:length(tank)
                if norm([new_x, new_y] - tank(i).pos,2) <= cutDist
                    invalid = 1;
                end
            end
            
            % if valid, add to mine struct and increment counter
            if invalid == 0
                mine(length(mine)+1).pos = [new_x, new_y];
                mine(length(mine)).val = 20*ceil(rand*5);
                mines = mines + 1;
            end
            
            % increment iteration counter and stop of too many
            iter = iter + 1;
            if iter >= maxIter
                break
            end
            
        end % end
        
        % create opposite side tanks and mines
        for i = 1:length(tank)
            atank(i).pos = [params.game.x_max, 2*tank(i).pos(2)] - tank(i).pos;
            atank(i).val = tank(i).val;
        end
        
        for i = 1:length(mine)
            amine(i).pos = [params.game.x_max, 2*mine(i).pos(2)] - mine(i).pos;
            amine(i).val = mine(i).val;
        end
        
        % append tank and mine fields to map struct
        map.tank = [tank, atank];
        map.mine = [mine, amine];
        
        % create first and second starting positions (symmetric)
        map.start(1).pos = [rand*(x_max-x_min) + x_min, rand*(y_max-y_min) + y_min];
        map.start(2).pos = [params.game.x_max-map.start(1).pos(1), map.start(1).pos(2)];
        
    end % end create_symrand

    function [map] = create_asymrand(params, nTanks,nMines, cutDist, maxIter)
        % creates asymrand map
        
        % start things off
        map.name = 'AsymRand';
        map.turn = 0;
        map.robot = [];
        
        % extract map dimensions
        x_max = params.game.x_max;
        x_min = params.game.x_min;
        y_max = params.game.y_max;
        y_min = params.game.y_min;
        
        % initialize iteration coun ter
        iter = 0;
        
        % initalize tank counter and tank struct
        tanks = 0;
        tank = [];
        while tanks <= nTanks
            
            % get a new point candidate
            new_x = rand*(x_max-x_min) + x_min;
            new_y = rand*(y_max-y_min) + y_min;
            
            % check if point is valid
            invalid = 0;
            for i = 1:length(tank)
                if norm([new_x, new_y] - tank(i).pos,2) <= cutDist
                    invalid = 1;
                end
            end
            
            % if valid point, add to tank struct and increment counter
            if ~invalid
                tank(length(tank)+1).pos = [new_x, new_y];
                tank(length(tank)).val = 50*ceil(rand*6);
                tanks = tanks + 1;
            end
            
            % increment iteration counter and stop if necesary
            iter = iter + 1;
            if iter >= maxIter
                break
            end
            
        end % end
        
        % initialize mine counter and struct
        mines = 0;
        mine = [];
        while mines <= nMines
            
            % get new point candidate
            new_x = rand*(x_max-x_min) + x_min;
            new_y = rand*(y_max-y_min) + y_min;
            
            % check if point is valid
            invalid = 0;
            for i = 1:length(mine)
                if norm([new_x, new_y] - mine(i).pos,2) <= cutDist/2
                    invalid = 1;
                end
            end
            
            % also check if valid relative to tanks placed.
            for i = 1:length(tank)
                if norm([new_x, new_y] - tank(i).pos,2) <= cutDist/2
                    invalid = 1;
                end
            end
            
            % add to mine struct if valid
            if ~invalid
                mine(length(mine)+1).pos = [new_x, new_y];
                mine(length(mine)).val = 20*ceil(rand*5);
                mines = mines + 1;
            end
            
            % increment iteration counter and stop if necesary
            iter = iter + 1;
            if iter >= maxIter
                error('Exceeded maximum number of iterations')
            end
            
        end % end
        
        % add tank and mine fields to map struct
        map.tank = tank;
        map.mine = mine;
        
        % generate random start positions
        map.start(1).pos = [rand*(x_max-x_min) + x_min, rand*(y_max-y_min) + y_min];
        
        % add only if start position is far enough
        valid = 0;
        while valid == 0
            
            new_pos = [rand*(x_max-x_min) + x_min, rand*(y_max-y_min) + y_min];
            
            if norm(new_pos-map.start(1).pos,2) >= 4*cutDist
                valid = 1;
            end
            
        end
        
        % add second start positions
        map.start(2).pos = new_pos;
        
    end % end create_asymrand


end % end get_map

function [params] = get_params(show, speed)

% GET_PARAMS gets default parameters for a battle.
%
% description:
%   subfunction for battle.m. responsibilities are to assign show boolean
%   along with other default parameters to params struct
%

% game params
params.game.nTurns = 1000;
params.game.end_dist = 5;
params.game.show = show;

params.game.tol = 1e-6;
params.game.v_max = 3;
params.game.t_max = 1e-1;

params.game.f_0 = 1000;
params.game.f_max = 1500;
params.game.f_idle = 2;
params.game.f_fun = @(dx, dy, idle) dx*dx + dy*dy + idle;
params.game.f_dist = 2;

params.game.m_dist = 5;

params.game.x_max = 100;
params.game.x_min = 0;
params.game.y_max = 100;
params.game.y_min = 0;

% graphic params
params.graphics.title_size = 12;
params.graphics.text_offset = 4;
params.graphics.text_size = 8;
params.graphics.border_line = 10;
params.graphics.border_offset = 4;
params.graphics.arena_offset = 4;

params.graphics.robot_diam = 20;
params.graphics.robot_line = 2;

params.graphics.tank_diam = 15;
params.graphics.tank_color = [0 0 1];
params.graphics.tank_ecolor = [0 .5 .5];
params.graphics.tank_line = 2;

params.graphics.mine_diam = 15;
params.graphics.mine_color = [1 0 0];
params.graphics.mine_line = 2;

params.graphics.device_textsize = 10;
params.graphics.winscreen_text = 35;

params.graphics.pause_time = 1/(10*speed+1e-5);

end % end get_params