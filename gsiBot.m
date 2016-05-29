function [out] = gsiBot(self, enemy, tank, mine)
%
% test robot for students during E7 robot tournament. Feel free to use this
% code to get your started.
%
% note that a robot of this caliber will not be competitive in the final
% tournament. the robots in the tournament will be much stronger.
%

% set up parameters for robot
params.speed_fuel = 2;
params.speed_end = 2.5;

if ~isempty(tank)
    
    % start d at infinity
    d = inf;
    I = 0;
    
    % loop through fuel tanks checking if current fuel tank is
    % closer than previous closest.
    for i = 1:length(tank)
        
        % get distance to this fuel tank
        D = norm(tank(i).pos - self.pos);
        if  D < d
            d = D;
            I = i;
        end
    end
    
    % make movement towards closest fuel tank
    dx = (params.speed_fuel/d)*(tank(I).pos(1)-self.pos(1));
    dy = (params.speed_fuel/d)*(tank(I).pos(2)-self.pos(2));
    
    % assign output
    out = [dx, dy];
    
else
    
    % get distance to enemy
    d = norm(self.pos - enemy.pos);
    
    % make movement toward enemy
    dx = (params.speed_end/d)*(enemy.pos(1)-self.pos(1));
    dy = (params.speed_end/d)*(enemy.pos(2)-self.pos(2));
    
    % assign output
    out = [dx, dy];
    
end

end % end gsiBot


