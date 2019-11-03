function status = del(filename)
%myFun - Description
%
% Syntax: output = myFun(input)
%
% delete file
    status = -1;
    filepath = strcat("detect_zone\\",filename);
    if exist(filepath, "file")
        delete(filepath);
        status = 0;
    end
end