clear;

disp("按空格键开始游戏");
pause();

new_world = World();

t = 0;
while true
    if detector('restart')
        new_world.reset();
        del('restart');
        del('jump');
        del('squat');
        del('pause');
    end
    tic;
    pause(0.002);
    new_world.update();
    t = toc + t;
    if t >= 0.015
        tic;
        new_world.visualize();
        t = toc;
    end
end
