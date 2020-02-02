clear;

r = 60; % 默认仿真频率60hz
fps = 30; % 默认fps30hz
f2dt = @(x)floor(1000*(1/x))/1000;
new_world = World(f2dt(r),f2dt(fps));