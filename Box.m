classdef Box < handle
    %UNTITLED �˴���ʾ�йش����ժҪ
    %   ���޴�߽�
    
    properties
        points;
        print;
    end
    
    methods
        function obj = Box(points)
            %UNTITLED ��������ʵ��
            %   creat a box
            obj.points = points;
        end
        
        function picture = draw(obj)
            %METHOD1 �˴���ʾ�йش˷�����ժҪ
            %   ����
            picture = plot(obj.points(1,:), obj.points(2,:));
        end
    end
end

