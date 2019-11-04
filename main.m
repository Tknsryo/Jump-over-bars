clear;

disp("按空格键开始游戏");
pause();

new_world = World();

while true
    pause(0.02);
    new_world.update();
    new_world.visualize(); 
end
