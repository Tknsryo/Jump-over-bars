classdef  World < handle
    properties 
        time;
        real_time;
        init_time;
        velocity;
        width;
        height;
        ceil_bs;
        barriers;
        barrier_prints;
        place_barriers_time;
        window;
        sub_window;
        info;
        player;
        player_print;
    end
    methods 
        function obj = World()
            obj.real_time = clock;
            obj.real_time = obj.real_time(end-2)*60 + obj.real_time(end-1)*60 + obj.real_time(end);
            obj.time = obj.real_time;
            obj.init_time = obj.real_time;
            obj.velocity = -2;
            obj.width = 16;
            obj.height = 9;
            obj.barriers = {};obj.barrier_prints = {};
            obj.place_barriers_time = obj.time + 1;
            obj.window = figure('name','Jump over bars');
            obj.sub_window = axes();
            obj.player = Box([3,10],2,2,'y'); %customize the player
            obj.player_print = obj.player.draw();
            set(obj.player_print,'Parent',obj.sub_window);
            set(obj.sub_window,'xlim',[0,16]);
            set(obj.sub_window,'ylim',[0,9]);
        end

        function update(obj)
        %myFun - Description
        %
        % Syntax: myFun(input)
        %
        % update the world
            %disp(obj.time-obj.init_time);
            if detector('pause')
                dt = clock;
                obj.real_time = dt(end-2)*60 + dt(end-1)*60 + dt(end);
            else
                dt = clock;
                dt = dt(end-2)*60 + dt(end-1)*60 + dt(end) - obj.real_time;
                obj.time = dt + obj.time;
                obj.real_time = dt + obj.real_time;
                %disp(obj.barriers{end});
                obj.info = ['t = ', num2str(obj.time-obj.init_time)];
                if ~isempty(obj.barriers) && (obj.barriers{1}.displacement < 0.5)
                    delete(obj.barrier_prints{1});
                    delete(obj.barriers{1});
                    obj.barriers(1) = [];
                    obj.barrier_prints(1) = [];
                end

                if obj.time - obj.place_barriers_time > 0
                    obj.barriers{end+1} = Barrier([2+2*rand,0,obj.width]);
                    set(obj.sub_window,'NextPlot','add');
                    obj.barrier_prints{end+1} = obj.barriers{end}.draw();
                    set(obj.sub_window,'NextPlot','replace');
                    obj.place_barriers_time = obj.time + 2 + rand;
                    obj.velocity = obj.velocity - 100*dt;
                end

                for i = 1:length(obj.barriers)
                    obj.barriers{i}.move(obj.velocity*dt);
                end
                %disp(dt);
                if obj.player.state == 0 && detector('jump') % jumping detector
                        obj.player.v = 11;
                end
                if detector('squat') % squat detector
                    obj.player.target = obj.player.half_hei/3;
                else
                    obj.player.target = obj.player.half_hei;
                end
                obj.player.update(-15,dt);
                if obj.iscollision()
                    disp('Game over.')
                    obj.info = ['Game over! t = ', num2str(obj.time-obj.init_time)];
                    set(obj.sub_window.XLabel,'String',obj.info);
                    add('restart');
                    disp('按空格再来一次');
                    pause();
                end
            end
        end
        function result = iscollision(obj)
        %myFun - Description
        %
        % Syntax: output = myFun(input)
        %
        % collision detector
            result = false;
            yp = obj.player.center(2)-obj.player.current(2);
            xp1 = obj.player.center(1)-obj.player.current(1);
            xp2 = obj.player.center(1)+obj.player.current(1);
            for i = 1:length(obj.barriers)
                b = obj.barriers{i};
                if b.displacement > xp2 
                    break;
                end
                if yp < b.len && xp1 < b.displacement && xp2 > b.displacement
                    result = true;
                end
            end
        end
        function visualize(obj)
            % 可视化
            if ~isgraphics(obj.window)
                disp('Press space to move on.');
                pause();
                obj.fix_window();
                dt = clock;
                obj.real_time = dt(end-2)*60 + dt(end-1)*60 + dt(end);
            end
            set(obj.sub_window.XLabel,'String',obj.info);
            set(obj.sub_window,'NextPlot','add');
            for i = 1:length(obj.barriers)
                p = obj.barrier_prints{i};
                pla = obj.barriers{i}.displacement;
                set(p,'xdata',[pla, pla]);
            end
            set(obj.player_print,'Vertices',obj.player.get_points());
            set(obj.sub_window,'NextPlot','replace');
        end

        function fix_window(obj)
            % fix the broken window.
            obj.window = figure('name','test');
            obj.sub_window = axes();
            set(obj.sub_window,'xlim',[0,16]);
            set(obj.sub_window,'ylim',[0,9]);
            obj.barrier_prints(1:end) = [];
            set(obj.sub_window,'NextPlot','add');
            obj.player_print = obj.player.draw();
            set(obj.player_print,'Parent',obj.sub_window);
            for i = 1:length(obj.barriers)
                obj.barrier_prints{i} = obj.barriers{i}.draw();
            end
            set(obj.sub_window,'NextPlot','replace');
        end

        function reset(obj)
            % reset the world
            obj.real_time = clock;
            obj.real_time = obj.real_time(end-2)*60 + obj.real_time(end-1)*60 + obj.real_time(end);
            obj.time = obj.real_time;
            obj.init_time = obj.real_time;
            obj.velocity = -2;
            for i = 1:length(obj.barriers)
                delete(obj.barrier_prints{i});
                delete(obj.barriers{i});
            end
            obj.barriers = {};obj.barrier_prints = {};
            obj.place_barriers_time = obj.time + 1;
            obj.player = Box([4,10],2,2,'y'); %customize the player
            obj.player_print = obj.player.draw();
            set(obj.player_print,'Parent',obj.sub_window);
            set(obj.sub_window,'xlim',[0,16]);
            set(obj.sub_window,'ylim',[0,9]);
        end
    end
end