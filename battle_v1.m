function [winner, err, errstr] = battle_v1(robot1, robot2, map_opt, show, speed)

% create params struct
params = get_params(show, speed);

if isa(robot1,'function_handle') && isa(robot2,'function_handle')
    % turn robot function handles into appropriate structs
    S = func2str(robot1);
    robot(1).team = S;
    robot(1).color = rand(1,3);
    robot(1).fun = robot1;
    robot(1).error = 0;
    robot(1).input.pos = [];
    robot(1).input.fuel = [];
    robot(1).input.prev = [];
    robot(1).mov = [];
    robot(1).t = []; 
    
    S = func2str(robot2);
    robot(2).team = S;
    robot(2).color = rand(1,3);
    robot(2).fun = robot2;
    robot(2).error = 0;
    robot(2).input.pos = [];
    robot(2).input.fuel = [];
    robot(2).input.prev = [];
    robot(2).mov = [];
    robot(2).t = [];
        
elseif isa(robot1, 'struct') && isa(robot2, 'struct')
    robot(1) = robot1;
    robot(2) = robot2;
end

% get map for this battle
map = get_map(robot, map_opt, params);

% if showing, initialize the handles
if params.game.show
    map = initialize_plot(map, params);
end

% loop through turns
for i = 0:params.game.nTurns
    
    % update turn number for map
    map.turn = i;
    
    % get moves from players
    map = get_moves(map, params);
    
    % check both players for errors
    for j = 1:2
        if map.robot(j).error
            winner = [];
            err = j;
            errstr = lasterror;
            close
            return
        end
    end
    
    % update state of game
    [winner, map] = update(map, params);
    
    % if the show flag is on, update the figure
    if params.game.show
        map = update_plot(map, params, winner);
    end
    
    % check for a winner (do it after plot state to give battle a
    % chance to display winner to screen)
    if ~isempty(winner)
        err = 0;
        errstr = [];
        close
        return
    end
    
end % end for i

% if it makes it to this line, then battle has timed out
winner = 0;
err = 0;
errstr = [];
close all

end % end battle.m

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

function [map] = get_map(robot, map_opt, params)

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
map.robot = robot;

% assign them default values
map.robot(1).input.pos = map.start(1).pos;
map.robot(1).input.fuel = params.game.f_0;
map.robot(1).input.prev = [0 0];
map.robot(2).input.pos = map.start(2).pos;
map.robot(2).input.fuel = params.game.f_0;
map.robot(2).input.prev = [0 0];

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

function [map] = get_moves(map, params)

% loop through players
for i = 1:2
    
    try
        
        tic
        mov = feval(map.robot(i).fun, ...
            map.robot(i).input,...
            map.robot(3-i).input,...
            map.tank,...
            map.mine);
        
        % get function time
        map.robot(i).t = toc;
        
        % check outputs for rule violations
        if ~isnumeric(mov)
            error('Robot Error: Output argument must be numeric')
        elseif length(mov) ~= 2
            error('Robot Error: Output argument must be a 1x2 numeric array')
        elseif any(~isreal(mov))
            error('Robot Error: Output argument must be real scalars')
        elseif any(isnan(mov))
            error('Robot Error: Output argument cannot be NaN')
        elseif norm(mov) >= params.game.v_max + params.game.tol
            disp('this happened')
            error('Robot Error: Moved %8.5f distance units. Maximum allowed movement per turn is %d units',...
                norm(mov, 2), params.game.v_max);
        end
        
        % if there are no errors, record what happened for this move.
        map.robot(i).mov = mov;
        
    catch
        
        map.robot(i).mov = [];
        map.robot(i).t = 0;
        map.robot(i).error = 1;
        return
        
    end % end try
    
end % end for

end % end get_moves

function [winner, map] = update(map, params)
% UPDATE updates the state of the game
%
% description:
%   subfunction for battle.m. responsibility is to update all aspects of
%   the game and check for winners

% check immediately for winner (also check if both players have run out of
% fuel to end game right away)
if norm(map.robot(1).input.pos - map.robot(2).input.pos,2) <= params.game.end_dist || and(map.robot(1).input.fuel == 0, map.robot(2).input.fuel==0)
    if map.robot(1).input.fuel > map.robot(2).input.fuel
        winner = 1;
    elseif map.robot(1).input.fuel < map.robot(2).input.fuel
        winner = 2;
    elseif and(map.robot(1).input.fuel == 0, map.robot(2).input.fuel==0)
        winner = 0;
    else
        winner = 0;
    end
    return
end

% otherwise set winner to empty
winner = [];

% initialize list of tanks to be deleted
tank_del = zeros(1,length(map.tank));

% check if players have acquired any fuel tanks
for i = 1:2
    for j = 1:length(map.tank)
        if norm(map.robot(i).input.pos - map.tank(j).pos, 2) <= params.game.f_dist
            map.robot(i).input.fuel = min([params.game.f_max, map.robot(i).input.fuel + map.tank(j).val]);
            map.handle.tank(j).delete = 1;
            tank_del(j) = 1;
        end
    end
end

% make deletions to struct
map.tank(tank_del==1) = [];

% initialize list of tanks to be deleted
mine_del = zeros(1,length(map.mine));

% check if players have hit any mines
for i = 1:2
    for j = 1:length(map.mine)
        if norm(map.robot(i).input.pos - map.mine(j).pos, 2) <= params.game.f_dist
            map.robot(i).input.fuel = max([0 , map.robot(i).input.fuel - map.mine(j).val]);
            map.handle.mine(j).delete = 1;
            mine_del(j) = 1;
        end
    end
end

% make deletions to struct
map.mine(mine_del==1) = [];

% update players
for i = 1:2
    
    % simple vector addition, everything should be ok by now
    if (map.robot(i).t <= params.game.t_max) && (map.robot(i).input.fuel > 0)
        map.robot(i).input.pos = map.robot(i).input.pos + map.robot(i).mov;
    end
    
    % no matter what happens, reduce fuel according to what movement robot
    % is trying to make. obviously, keep fuel level at or above 0.
    map.robot(i).input.fuel = max([0, map.robot(i).input.fuel - params.game.f_fun(map.robot(i).mov(1), map.robot(i).mov(2), 2)]);
    
    % stop robot at walls
    if map.robot(i).input.pos(1) < params.game.x_min
        map.robot(i).input.pos(1) = params.game.x_min;
    elseif map.robot(i).input.pos(1) > params.game.x_max
        map.robot(i).input.pos(1) = params.game.x_max;
    end
    
    if map.robot(i).input.pos(2) < params.game.y_min
        map.robot(i).input.pos(2) = params.game.y_min;
    elseif map.robot(i).input.pos(2) > params.game.y_max
        map.robot(i).input.pos(2) = params.game.y_max;
    end
    
    % record output into prev
    map.robot(i).input.prev = map.robot(i).mov;
    
end

end % end update

function [map] = update_plot(map, params, winner)

% update title
set(map.handle.title, 'String', sprintf('%s vs. %s\nTurn: %d',...
    map.robot(1).team,...
    map.robot(2).team,...
    map.turn))

% display winner screen if necesary
if ~isempty(winner)
    switch winner
        case 0
            text((params.game.x_min + params.game.x_max)/2,...
                (params.game.y_min + params.game.y_max)/2,...
                'Players Tie',...
                'FontWeight', 'bold',...
                'FontSize', params.graphics.winscreen_text,...
                'HorizontalAlignment', 'center')
        otherwise
            text((params.game.x_min + params.game.x_max)/2,...
                (params.game.y_min + params.game.y_max)/2,...
                sprintf('%s Wins!', map.robot(winner).team),...
                'FontWeight', 'bold',...
                'FontSize', params.graphics.winscreen_text,...
                'HorizontalAlignment', 'center')
            
    end % end switch
    
    pause(2)
    
end % end if

% delete handle, then delete struct element
tank_del = zeros(1,length(map.handle.tank));
for i = 1:length(map.handle.tank)
    if map.handle.tank(i).delete
        delete(map.handle.tank(i).body);
        delete(map.handle.tank(i).text);
        tank_del(i) = 1;
    end
end

% make erases
map.handle.tank(tank_del==1) = [];

% delete handle, then delete struct element
mine_del = zeros(1,length(map.handle.mine));
for i = 1:length(map.handle.mine)
    if map.handle.mine(i).delete
        delete(map.handle.mine(i).body);
        delete(map.handle.mine(i).text);
        mine_del(i) = 1;
    end
end

% make erases
map.handle.mine(mine_del==1) = [];

for i = 1:2
    % set robot positions
    set(map.handle.robot(i).body,...
        'XData', map.robot(i).input.pos(1),...
        'YData', map.robot(i).input.pos(2))
    set(map.handle.robot(i).text,...
        'Position',...
        map.robot(i).input.pos + [params.graphics.text_offset, -params.graphics.text_offset],...
        'String',...
        sprintf('%s\nX: %d\nY: %d\nFuel: %d',...
        map.robot(i).team,...
        round(map.robot(i).input.pos(1)),...
        round(map.robot(i).input.pos(2)),...
        round(map.robot(i).input.fuel)))
end

% pause screen for viewing
pause(params.graphics.pause_time)

end % end update_plot

function [map] = initialize_plot(map, params)

% initialize handles struct
handle = [];

figure
hold on

% figure cosmetics and titling
set(gcf, 'NumberTitle', 'off')
set(gcf, 'Toolbar', 'none')
set(gcf, 'Name', sprintf('Current Battle: %s vs. %s',...
    map.robot(1).team,...
    map.robot(2).team))
set(gcf, 'MenuBar', 'none')
set(gcf, 'Units', 'normalized')
set(gcf, 'Position', [.1 .1 .8 .8])

% print title of screen on backdrop
text((params.game.x_min + params.game.x_max)/2,...
    (params.game.y_min + params.game.y_max)/2,...
    sprintf('%s', map.name),...
    'FontSize', 50,...
    'FontWeight', 'bold',...
    'HorizontalAlignment', 'center',...
    'color', [.9 .9 .9])

% plot border
plot([params.game.x_min-params.graphics.border_offset,...
    params.game.x_max+params.graphics.border_offset,...
    params.game.x_max+params.graphics.border_offset,...
    params.game.x_min-params.graphics.border_offset,...
    params.game.x_min-params.graphics.border_offset],...
    [params.game.y_min-params.graphics.border_offset,...
    params.game.y_min-params.graphics.border_offset,...
    params.game.y_max+params.graphics.border_offset,...
    params.game.y_max+params.graphics.border_offset,...
    params.game.y_min-params.graphics.border_offset],...
    'Color', 'k',...
    'LineWidth', params.graphics.border_line)

% set the axis up
axis([params.game.x_min-params.graphics.arena_offset,...
    params.game.x_max+params.graphics.arena_offset,...
    params.game.y_min-params.graphics.arena_offset,...
    params.game.y_max+params.graphics.arena_offset])
axis off
axis equal

% assign title handle
handle.title = title(sprintf('%s vs. %s\nTurn: %d',...
    map.robot(1).team,...
    map.robot(2).team,...
    map.turn),...
    'FontSize', params.graphics.title_size,...
    'FontWeight', 'bold',...
    'Color', 'k');

% plot and assign robot handles
for i = 1:2
    handle.robot(i).body = plot(map.robot(i).input.pos(1), map.robot(i).input.pos(2),...
        'o', 'MarkerSize', params.graphics.robot_diam,...
        'MarkerFaceColor', map.robot(i).color,...
        'MarkerEdgeColor', 'k',...
        'LineWidth', params.graphics.robot_line);
    
    % plot the accompanying text
    handle.robot(i).text = text(map.robot(i).input.pos(1) + params.graphics.text_offset,...
        map.robot(i).input.pos(2) - params.graphics.text_offset,...
        sprintf('%s\nX: %d\nY: %d\nFuel: %d',...
        map.robot(i).team,...
        round(map.robot(i).input.pos(1)),...
        round(map.robot(i).input.pos(2)),...
        round(map.robot(i).input.fuel)),...
        'FontWeight', 'bold',...
        'FontSize', params.graphics.text_size);
end

% assign tank graphic handles
for i = 1:length(map.tank)
    handle.tank(i).body = plot(map.tank(i).pos(1),...
        map.tank(i).pos(2), 'o',...
        'MarkerSize', params.graphics.tank_diam,...
        'MarkerFaceColor', params.graphics.tank_color,...
        'MarkerEdgeColor', params.graphics.tank_ecolor,...
        'LineWidth', params.graphics.tank_line);
    handle.tank(i).text = text(map.tank(i).pos(1),...
        map.tank(i).pos(2),...
        num2str(map.tank(i).val),...
        'FontWeight', 'bold',...
        'FontSize', params.graphics.device_textsize,...
        'HorizontalAlignment', 'center',...
        'VerticalAlignment', 'middle');
    handle.tank(i).delete = 0;
end

% assign mine graphic handles
for i = 1:length(map.mine)
    handle.mine(i).body = plot(map.mine(i).pos(1),...
        map.mine(i).pos(2), '*',...
        'MarkerSize', params.graphics.mine_diam,...
        'MarkerEdgeColor', params.graphics.mine_color,...
        'LineWidth', params.graphics.mine_line);
    handle.mine(i).text = text(map.mine(i).pos(1),...
        map.mine(i).pos(2),...
        num2str(map.mine(i).val),...
        'FontWeight', 'bold',...
        'FontSize', params.graphics.device_textsize,...
        'HorizontalAlignment', 'center',...
        'VerticalAlignment', 'middle');
    handle.mine(i).delete = 0;
end

% assign handles to map
map.handle = handle;

end % end initialize plot