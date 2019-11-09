classdef Box < handle
    %UNTITLED 此处显示有关此类的摘要
    % 骚骚的矩形
    
    properties
        points;
        half_wid;
        half_hei;
        area;
        target;
        current;
        center;
        v;
        color;
        print;
        state;
        pattern;
    end
    
    methods
        function obj = Box(center,width,heigth,col)
            %UNTITLED 构造此类的实例
            %   creat a box
            obj.center = center;
            obj.half_wid = width/2;
            obj.half_hei = heigth/2;
            obj.current = [width/2, heigth/2];
            obj.area = obj.half_hei*obj.half_wid + obj.half_wid;
            obj.target = [1,1];
            obj.points = [center(1)-obj.half_wid,center(1)+obj.half_wid,...
            center(1)+obj.half_wid,center(1)-obj.half_wid;...
            center(2)-obj.half_hei,center(2)-obj.half_hei,...
            center(2)+obj.half_hei,center(2)+obj.half_hei;...
            ];
            obj.pattern = Pattern('default.mat'); %自定义角色皮肤
            obj.color = col;
            obj.state = 0;
            obj.v = 0;
        end
        
        function picture = draw(obj)
            %METHOD1 此处显示有关此方法的摘要
            %   返回图形对象
            picture{1} = fill(obj.points(1,:), obj.points(2,:),obj.color);
            for i = 1:length(obj.pattern.points)
                r = (obj.pattern.points{i} - 0.5).*[obj.current(1);obj.current(2)]+[obj.center(1);obj.center(2)];
                picture{2}{i} = plot(r(1,:),r(2,:),'k','linewidth',2);
            end
        end

        function points = get_points(obj)
            % 返回当前顶点
            points{1} = [obj.center(1)-obj.current(1),obj.center(2)-obj.current(2);...
            obj.center(1)+obj.current(1),obj.center(2)-obj.current(2);...
            obj.center(1)+obj.current(1),obj.center(2)+obj.current(2);...
            obj.center(1)-obj.current(1),obj.center(2)+obj.current(2)];
            for i = 1:length(obj.pattern.points)
                points{2}{i} = (obj.pattern.points{i} - 0.5).*[obj.current(1);obj.current(2)]+[obj.center(1);obj.center(2)];
            end
        end

        function update(obj,acc,dt)
        %myFun - Description
        %
        % Syntax: output = myFun(input)
        %
        % update the velocity, position and shape of the box
            if  obj.state == 0 && obj.center(2)-obj.current(2) > 0
                obj.state = 1;
            end
            %滞空时改变位形的核心算法
            if obj.state
                vp = obj.v;
                obj.v = obj.v + acc*dt;
                dy = (vp + obj.v)*dt/2;
                obj.center(2) = obj.center(2) + dy;
                if obj.center(2)-obj.current(2) <= 0
                    obj.state = 0;
                    obj.v = 0;
                end
                obj.current(2) = obj.current(2) - 4*(obj.current(2)-obj.target(2)*obj.half_hei)*dt;
                obj.current(1) = obj.area/(obj.current(2)+1);
                obj.target(1) = obj.current(1)/obj.half_wid;
            end
            %触地时改变位形的核心算法
            if obj.state == 0
                if obj.v > 0
                    obj.current(2) = obj.current(2) + obj.v*dt;
                else
                    obj.current(2) = obj.current(2) - 4*(obj.current(2)-obj.target(2)*obj.half_hei)*dt;
                end
                obj.current(1) = obj.area/(obj.current(2)+1);
                obj.target(1) = obj.current(1)/obj.half_wid;
                obj.center(2) = obj.current(2);
            end
            if obj.center(2) >= obj.half_hei + 1 && obj.v > 0
                obj.state = 1;
                obj.target(2) = 1;
            end
        end
    end
end

