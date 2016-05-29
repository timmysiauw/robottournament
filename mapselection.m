
maps = [];

done = 0;
while ~done
    
    close all
    hold on
    
    map = get_map('asym');
    
    for i = 1:length(map.tank)
        plot(map.tank(i).pos(1), map.tank(i).pos(2), 'bo')
    end
    
    for i = 1:length(map.mine)
        plot(map.mine(i).pos(1), map.mine(i).pos(2), 'r*')
    end
    
    plot(map.start(1).pos(1), map.start(1).pos(2), 'go')
    plot(map.start(2).pos(1), map.start(2).pos(2), 'go')
    
    option = input('Do you wish to keep map?');
    
    if option == 0
        continue
    elseif option == 1
        maps = [maps, map];
    elseif option == 2
        done = 1;
    end
    
end