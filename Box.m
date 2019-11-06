classdef Box < handle
    %UNTITLED 此处显示有关此类的摘要
    %   无限大边界
    
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
            obj.target = heigth/2;
            obj.points = [center(1)-obj.half_wid,center(1)+obj.half_wid,...
            center(1)+obj.half_wid,center(1)-obj.half_wid;...
            center(2)-obj.half_hei,center(2)-obj.half_hei,...
            center(2)+obj.half_hei,center(2)+obj.half_hei;...
            ];
            obj.color = col;
            obj.state = 0;
            obj.v = 0;
        end
        
        function picture = draw(obj)
            %METHOD1 此处显示有关此方法的摘要
            %   返回图形对象
            picture = fill(obj.points(1,:), obj.points(2,:),obj.color);
        end

        function points = get_points(obj)
            % 返回当前顶点
            points = [obj.center(1)-obj.current(1),obj.center(2)-obj.current(2);...
            obj.center(1)+obj.current(1),obj.center(2)-obj.current(2);...
            obj.center(1)+obj.current(1),obj.center(2)+obj.current(2);...
            obj.center(1)-obj.current(1),obj.center(2)+obj.current(2)];
        end

        function update(obj,acc,dt)
        %myFun - Description
        %
        % Syntax: output = myFun(input)
        %
        % update the velocity and position and shape of the box
            %disp(obj.center(2));
            if  obj.state == 0 && obj.center(2)-obj.current(2) > 0
                obj.state = 1;
            end
            if obj.state
                vp = obj.v;
                obj.v = obj.v + acc*dt;
                dy = (vp + obj.v)*dt/2;
                obj.center(2) = obj.center(2) + dy;
                %obj.points(2,:) = obj.points(2,:) + dy;
                if obj.center(2)-obj.current(2) <= 0
                    obj.state = 0;
                    obj.v = 0;
                end
                obj.current(2) = obj.current(2) - 4*(obj.current(2)-obj.target)*dt;
                obj.current(1) = obj.area/(obj.current(2)+1);
            end

            if obj.state == 0
                if obj.v > 0
                    obj.current(2) = obj.current(2) + obj.v*dt;
                else
                    obj.current(2) = obj.current(2) - 4*(obj.current(2)-obj.target)*dt;
                end
                obj.current(1) = obj.area/(obj.current(2)+1);
                obj.center(2) = obj.current(2);
            end
            if obj.center(2) >= obj.half_hei + 1 && obj.v > 0
                obj.state = 1;
                obj.target = obj.half_hei;
            end
        end
    end
end

