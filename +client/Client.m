classdef  Client < handle
% Used for interacting with the background server(Bg server) and the game,
% or receiving data from them.
    properties (Access = public)
        socket;
        address;
        port;
        recvTimer;
        gameData;
        maxLen;
    end
    methods
        function obj = Client(address,port)
            obj.socket = [];
            obj.setServer(address,port);
            obj.initRecvTimer(0.01);
            obj.gameData = [];
            obj.maxLen = 0;
            obj.connect();
        end
        function setServer(obj,address,port)
            %determine the address and port
            obj.address = address;
            obj.port = port;
        end
        function set.maxLen(obj,len)
            if len >= 0
                obj.maxLen = len;
            else
                disp('maxLen: unsupported value');
            end
        end
        function initRecvTimer(obj,period)
        % initialize a timer for socket reading
            obj.recvTimer = timer;
            set(obj.recvTimer,'ExecutionMode','fixedRate');
            set(obj.recvTimer,'period',period);
            set(obj.recvTimer,'TimerFcn',@obj.readSocket);
        end
        function readSocket(obj,~,~)
            if ~isempty(obj.socket) && obj.socket.BytesAvailable > 0
                data = obj.socket.read(1);
                switch data
                case '~'
                    header = obj.socket.read(3); %type|frameLen|batchs
                    while obj.socket.BytesAvailable < header(2) % wait for incoming data
                        continue;
                    end
                    switch header(1)
                    case 'm' %message
                        sdata = obj.socket.read(header(2));
                        disp('*message from the server:');
                        disp(char(sdata));
                        disp('*')
                    case 'd' %game's data
                        obj.gameData(end+1).time = obj.socket.read(1,'double');
                        obj.gameData(end).stat = obj.socket.read(1);
                        obj.gameData(end).jump = obj.socket.read(1);
                        obj.gameData(end).squat = obj.socket.read(1);
                        obj.gameData(end).dis = obj.socket.read(3,'double');
                        obj.gameData(end).len = obj.socket.read(3,'double');
                        obj.socket.read(1);
                        while obj.maxLen > 0 && length(obj.gameData) > obj.maxLen
                            obj.gameData(1) = [];
                        end
                    end
                otherwise
                    obj.socket.read();
                end
            end
        end
        function connect(obj)
        % connect to the background server
            if isempty(obj.socket)
                disp('connecting');
                try
                    obj.socket = tcpclient(obj.address,obj.port,...
                    'ConnectTimeout',1);
                catch
                    disp('Fail to connect to background');
                    obj.socket = [];
                end
            else
                disp('connected');
                return;
            end
            if isempty(obj.socket)
                disp('fail to connect');
            else
                disp('connect successfully');
                start(obj.recvTimer);
            end
        end
        function  disconnect(obj)
        % disconnect from the background server
            if ~isempty(obj.socket)
                stop(obj.recvTimer);
                delete(obj.socket);
                obj.socket = [];
                disp('disconnected');
            end
        end
        function send(obj,header,data)
            if ~isempty(obj.socket)
                obj.socket.write(header);
                obj.socket.write(data);
            else
                disp('send error: disconnected');
            end
        end
        function jump(obj,x)
            if x > 0
                obj.send(uint8(['~r',5,1]),uint8(['~k',1,1,'j']));
            else
                obj.send(uint8(['~r',5,1]),uint8(['~k',1,1,'n']));
            end
        end
        function squat(obj,x)
            if x > 0
                obj.send(uint8(['~r',5,1]),uint8(['~k',1,1,'k']));
            else
                obj.send(uint8(['~r',5,1]),uint8(['~k',1,1,'m']));
            end
        end
        function pause(obj)
            obj.send(uint8(['~r',5,1]),uint8(['~k',1,1,'l']));
        end
        function reset(obj)
            obj.send(uint8(['~r',5,1]),uint8(['~k',1,1,'r']));
        end
        function configure(obj,key,value)
        % configure settings of the BG server or the game.
            switch key
            case 'reqDataFromBg' % require data from Bg server.
                if value == 1
                    obj.send(uint8(['~s',2,1]),uint8(['t',1]));
                elseif value == 0
                    obj.send(uint8(['~s',2,1]),uint8(['t',0]));
                end
            case 'reqDataFromGame' % require data from game to Bg server.
                if value == 1
                    obj.send(uint8(['~r',6,1]),uint8(['~s',2,1,'s',1]));
                elseif value == 0
                    obj.send(uint8(['~r',6,1]),uint8(['~s',2,1,'s',0]));
                end
            case 'fps' % configure fps (10~60HZ)
                if value >= 10 && value <= 60
                    obj.send(uint8(['~r',6,1]),uint8(['~s',2,1,'f',value]));
                else
                    disp('fps: unsupported value');
                end
            case 'simulRate' % configure simulation rate (10~120HZ)
                if value >= 10 && value <= 120
                    obj.send(uint8(['~r',6,1]),uint8(['~s',2,1,'r',value]));
                else
                    disp('simulation rete: unsupported value');
                end
            case 'recvRate' % configure data recving rate from the game (1~60HZ)
                if value >= 1 && value <= 60
                    obj.send(uint8(['~r',6,1]),uint8(['~s',2,1,'c',value]));
                else
                    disp('simulation rete: unsupported value');
                end
            case 'autoRestart' % whether to restart the game when gameover(require 'reqDataFromGame')
                if value == 1
                    obj.send(uint8(['~s',2,1]),uint8(['r',1]));
                elseif value == 0
                    obj.send(uint8(['~s',2,1]),uint8(['r',0]));
                end
            case 'dispInBg' % whether to display the data from the game on the Bg server console
                if value == 1
                    obj.send(uint8(['~s',2,1]),uint8(['d',1]));
                elseif value == 0
                    obj.send(uint8(['~s',2,1]),uint8(['d',0]));
                end
            otherwise
                disp('configure: unrecognized setting.');
            end
        end
        function toDisk(obj,filePath,openMode)
            % write data from the game to file.
            % openMode
            % w: write only
            % a: append
            data = [];
            switch openMode
            case 'w'
                data = uint8(['o',0,char(filePath)]);
            case 'a'
                data = uint8(['o',1,char(filePath)]);
            end
            if isempty(data)
                disp('toDisk: unrecognized open mode.');
                return
            end
            obj.send(uint8(['~s',length(data),1]),data);
        end
        function save(obj)
            obj.send(uint8(['~s',2,1]),uint8(['s',1]));
        end
        function gameIsRunning(obj)
            obj.send(uint8(['~q',1,1]),uint8(['g']));
        end
    end
end