function output = detector(filename)
%myFun - Description
%
% Syntax: output = myFun(input)
%
% detect files
    output = false;
    if ~exist("detect_zone","dir")
        mkdir("detect_zone");
    end
    if exist(strcat("detect_zone\\",filename), "file")
        output = true;
    end

end