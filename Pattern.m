classdef Pattern < handle
    % 自定义图案
    properties
        points;
    end

    methods 
        function obj = Pattern(point_path)
            % 标准化
            obj.points = struct2cell(load(point_path));
            if ~isempty(obj.points)
                    xmin = min(obj.points{1}(1,:));
                    ymin = min(obj.points{1}(2,:));
                    xmax = max(obj.points{1}(1,:));
                    ymax = max(obj.points{1}(2,:));
                for i = 2:length(obj.points)
                    if xmin > min(obj.points{i}(1,:))
                        xmin = min(obj.points{i}(1,:));
                    end
                    if ymin > min(obj.points{i}(2,:))
                        ymin = min(obj.points{i}(2,:));
                    end
                    if xmax < max(obj.points{i}(1,:))
                        xmax = max(obj.points{i}(1,:));
                    end
                    if ymax < max(obj.points{i}(2,:))
                        ymax = max(obj.points{i}(2,:));
                    end
                end
                for i = 1:length(obj.points)
                    obj.points{i}(1,:) = (obj.points{i}(1,:) - xmin)/(xmax-xmin);
                    obj.points{i}(2,:) = (obj.points{i}(2,:) - ymin)/(ymax-ymin);
                end
            end
        end
    end
end