clear;

disp("���ո����ʼ��Ϸ");
pause();

new_world = World();
del('restart');
del('eme');
del('jump');
del('squat');
del('pause');
t = 0;
dt = 0;
while true
    t0 = tic;
    while detector('eme')
        if detector('restart')
            new_world.reset();
            del('restart');
            del('eme');
            del('jump');
            del('squat');
            del('pause');
            t0 = tic;
            break;
        end
        pause(0.02);
    end
    if detector('restart')
        new_world.reset();
        del('restart');
        del('jump');
        del('squat');
        del('pause');
    end
    pause(0.007); % �����Ƶ���й�
    new_world.update(dt);
    if t >= 0.014 % ����fps����ǰ����ԼΪ60fps
        new_world.visualize();
    end
    dt = toc(t0);
    t = dt + t;
end
