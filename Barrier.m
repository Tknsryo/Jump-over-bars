classdef  Barrier < handle
    properties 
        len; % 长度
        position; % 地面上为0，天花板上为1
        displacement; % 相对右边界的位移
        parent;
    end
    methods 
        function obj = Barrier(args,ax)
            if length(args) >= 3
                obj.len = args(1);
                obj.position = args(2);
                obj.displacement = args(3);
                obj.parent = ax;
            end
        end

        function [d1, d2, d3] = get_data(obj)
        %myFun - Description
        %
        % Syntax: d1, d2, d3 = get_data(input)
        %
        % 返回数据
            d1 = obj.len;
            d2 = obj.position;
            d3 = obj.displacement;
        end

        function picture = draw(obj)
            %METHOD1 此处显示有关此方法的摘要
            %   画出
            picture = plot(obj.parent,[-1,-1],[0,obj.len],'linewidth',2);
        end

        function move(obj,x)
        %myFun - Description
        %
        % Syntax: myFun(input)
        %
        % displace
            obj.displacement = obj.displacement + x;
        end
    end
end