clear;

r = 60; % Ĭ�Ϸ���Ƶ��60hz
fps = 30; % Ĭ��fps30hz
f2dt = @(x)floor(1000*(1/x))/1000;
new_world = World(f2dt(r),f2dt(fps));