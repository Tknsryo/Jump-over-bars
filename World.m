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
        boundary;
        window;
        sub_window;
    end
    methods 
        function obj = World()
            obj.real_time = clock;
            obj.real_time = obj.real_time(end-2)*60 + obj.real_time(end-1)*60 + obj.real_time(end);
            obj.time = obj.real_time;
            obj.init_time = obj.real_time;
            obj.velocity = 3;
            obj.width = 16;
            obj.height = 9;
            box = [0, obj.width, obj.width, 0, 0,...
            ;0, 0, obj.height, obj.height, 0];
            obj.boundary = Box(box);
            obj.ceil_bs = {};obj.barriers = {};obj.barrier_prints = {};
            obj.place_barriers_time = obj.time + 1;
            obj.window = figure('name','test');
            obj.sub_window = axes();
            set(obj.sub_window,'xlim',[0,16]);
            set(obj.sub_window,'ylim',[0,9]);
        end

        function update(obj)
        %myFun - Description
        %
        % Syntax: myFun(input)
        %
        % update the world
            disp(obj.time-obj.init_time);
            if detector('pause')
                dt = clock;
                obj.real_time = dt(end-2)*60 + dt(end-1)*60 + dt(end);
            else
                dt = clock;
                dt = dt(end-2)*60 + dt(end-1)*60 + dt(end) - obj.real_time;
                obj.time = dt + obj.time;
                obj.real_time = dt + obj.real_time;

                if ~isempty(obj.barriers) && (obj.barriers{1}.displacement >= 15.5)
                    delete(obj.barriers{1});
                    delete(obj.barrier_prints{1});
                    obj.barriers(1) = [];
                    obj.barrier_prints(1) = [];
                end

                if obj.time - obj.place_barriers_time > 1
                    obj.barriers{end+1} = Barrier([3,0,0]);
                    set(obj.sub_window,'NextPlot','add');
                    obj.barrier_prints{end+1} = obj.barriers{end}.draw();
                    set(obj.sub_window,'NextPlot','replace');
                    obj.place_barriers_time = obj.time;
                end

                for i = 1:length(obj.barriers)
                    obj.barriers{i}.move(obj.velocity*dt);
                end
            end
        end

        function visualize(obj)
            if ~isgraphics(obj.window)
                disp('Press space to move on.');
                pause();
                obj.fix_window();
                dt = clock;
                obj.real_time = dt(end-2)*60 + dt(end-1)*60 + dt(end);
            end
            set(obj.sub_window.XLabel,'String',...
            ['t = ', num2str(obj.time-obj.init_time)]);
            set(obj.sub_window,'NextPlot','add');
            %set(f,'NextPlot','add');
            %set(a,'NextPlot','add');
            %p = obj.boundary.draw();
            %p.Parent = obj.sub_window;
            for i = 1:length(obj.barriers)
                %[len, flag, pla] = obj.barriers{i}.get_data();
                %if flag == 0
                %    x = [obj.width - pla, obj.width - pla];
                %    y = [0, len];
                %    plot(x,y);
                %end
                p = obj.barrier_prints{i};
                pla = obj.barriers{i}.displacement;
                set(p,'xdata',[obj.width - pla, obj.width - pla]);
            end
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
            for i = 1:length(obj.barriers)
                obj.barrier_prints{i} = obj.barriers{i}.draw();
            end
            set(obj.sub_window,'NextPlot','replace');
        end
    end
end