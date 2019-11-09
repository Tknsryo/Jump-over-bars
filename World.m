classdef  World < handle
    properties 
        interval;
        time;
        real_time;
        init_time;
        velocity;
        init_v;
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
        window_pause;
    end
    methods 
        function obj = World()
            obj.init_v = -3;%自定义栅栏初始速度
            obj.velocity = obj.init_v;
            obj.width = 24;%自定义空间大小
            obj.height = 9;
            obj.barriers = {};obj.barrier_prints = {};
            obj.window = figure('name','Jump over bars');
            set(obj.window,'Position',[100 100 1300 550]);%自定义窗口大小
            obj.window_pause = 0;
            obj.sub_window = axes();
            set(obj.sub_window,'NextPlot','add');
            obj.player = Box([3,11],2,2,'g'); %customize the player
            obj.player_print = obj.player.draw(); %获取玩家对象用于可视化的数据
            set(obj.player_print{1},'Parent',obj.sub_window);
            for i = 1:length(obj.player_print{2})
                set(obj.player_print{2}{i},'Parent',obj.sub_window);
            end
            set(obj.sub_window,'NextPlot','replace');
            set(obj.sub_window,'xlim',[0,obj.width]);
            set(obj.sub_window,'ylim',[0,obj.height]);
            obj.time = 0;
            obj.place_barriers_time = obj.time + 1;
        end

        function update(obj,dt)
        %myFun - Description
        %
        % Syntax: myFun(input)
        %
        % update the world
            %disp(obj.time-obj.init_time);
            if detector('pause')
                %dt = clock;
                %obj.real_time = dt(end-2)*60 + dt(end-1)*60 + dt(end);
            else
                if obj.window_pause
                    obj.fix_window();
                    obj.window_pause = 0;
                end
                obj.time = dt + obj.time;
                %disp(obj.barriers{end});
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
                    obj.place_barriers_time = obj.time + 2 + rand;%定义出栅栏的时间间隔
                    obj.velocity = obj.velocity - 10*dt; %定义每出一个栅栏速度的增加
                end

                for i = 1:length(obj.barriers)
                    obj.barriers{i}.move(obj.velocity*dt);
                end
                %disp(dt);
                if obj.player.state == 0 && detector('jump') % jumping detector
                        obj.player.v = 11;
                end
                if detector('squat') % squat detector
                    obj.player.target(2) = 1/3;
                else
                    obj.player.target(2) = 1;
                end
                obj.player.update(-15,dt);%第一个参数为重力加速度
                if obj.iscollision()
                    disp(['Game over. t = ', num2str(obj.time)]);
                    obj.info = ['Game over! t = ', num2str(obj.time)];
                    set(obj.sub_window.XLabel,'String',obj.info);
                    add('eme');
                    disp('按 R 再来一次');
                    %pause();
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

            if ~isgraphics(obj.sub_window)
                if ~detector('pause')
                    disp('Press L once or twice to move on.');
                end
                add('pause');
                obj.window_pause = 1;
            else
                set(obj.sub_window.XLabel,'String',obj.info);
                set(obj.sub_window,'NextPlot','add');
                %渲染栅栏
                for i = 1:length(obj.barriers)
                    p = obj.barrier_prints{i};
                    pla = obj.barriers{i}.displacement;
                    set(p,'xdata',[pla, pla]);
                end
                %渲染玩家
                ps = obj.player.get_points();
                set(obj.player_print{1},'Vertices',ps{1});
                for i = 1:length(ps{2})
                    set(obj.player_print{2}{i},'xdata',ps{2}{i}(1,:));
                    set(obj.player_print{2}{i},'ydata',ps{2}{i}(2,:));
                end
                set(obj.sub_window,'NextPlot','replace');
                obj.info = ['t = ', num2str(obj.time)];
                set(obj.sub_window.XLabel,'String',obj.info);
            end
        end

        function fix_window(obj)
            % fix the broken window.
            obj.window = figure('name','Jump over bars');
            set(obj.window,'Position',[100 100 1300 550]);
            obj.sub_window = axes();
            set(obj.sub_window,'xlim',[0,obj.width]);
            set(obj.sub_window,'ylim',[0,obj.height]);
            obj.barrier_prints(1:end) = [];
            set(obj.sub_window,'NextPlot','add');
            obj.player_print = obj.player.draw();
            set(obj.player_print{1},'Parent',obj.sub_window);
            for i = 1:length(obj.player_print{2})
                set(obj.player_print{2}{i},'Parent',obj.sub_window);
            end
            for i = 1:length(obj.barriers)
                obj.barrier_prints{i} = obj.barriers{i}.draw();
            end
            set(obj.sub_window,'NextPlot','replace');
        end

        function reset(obj)
            % reset the world
            obj.velocity = obj.init_v;
            for i = 1:length(obj.barriers)
                delete(obj.barrier_prints{i});
                delete(obj.barriers{i});
            end
            delete(obj.player_print{1});
            for i = 1:length(obj.player_print{2})
                delete(obj.player_print{2}{i});
            end
            obj.barriers = {};obj.barrier_prints = {};
            obj.player = Box([4,10],2,2,'g'); %customize the player
            if ~isgraphics(obj.window)
                obj.window = figure('name','Jump over bars');
                set(obj.window,'Position',[100 100 1300 550]);
            end
            delete(obj.sub_window);
            obj.sub_window = axes();
            set(obj.sub_window,'Parent',obj.window);
            set(obj.sub_window,'NextPlot','add');
            obj.player_print = obj.player.draw();
            set(obj.player_print{1},'Parent',obj.sub_window);
            for i = 1:length(obj.player_print{2})
                set(obj.player_print{2}{i},'Parent',obj.sub_window);
            end
            set(obj.sub_window,'xlim',[0,obj.width]);
            set(obj.sub_window,'ylim',[0,obj.height]);
            set(obj.sub_window,'NextPlot','replace');
            obj.time = 0;
            obj.place_barriers_time = obj.time + 1;
        end
    end
end