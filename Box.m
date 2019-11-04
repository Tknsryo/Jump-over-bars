classdef Box < handle
    %UNTITLED 此处显示有关此类的摘要
    %   无限大边界
    
    properties
        points;
        print;
    end
    
    methods
        function obj = Box(points)
            %UNTITLED 构造此类的实例
            %   creat a box
            obj.points = points;
        end
        
        function picture = draw(obj)
            %METHOD1 此处显示有关此方法的摘要
            %   画出
            picture = plot(obj.points(1,:), obj.points(2,:));
        end
    end
end

