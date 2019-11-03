function status = add(filename)
%myFun - Description
%
% Syntax: output = myFun(input)
%
% add file
    status = -1;
    if ~exist("detect_zone","dir")
        mkdir("detect_zone");
    end
    filepath = strcat("detect_zone\\",filename);
    if ~exist(filepath, "file")
        f = fopen(filepath,"w");
        status = fclose(f);
    end
end