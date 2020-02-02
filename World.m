classdef  World < handle
    properties 
        time;
        velocity;
        init_v;
        width;
        height;
        barriers;
        barrier_prints;
        place_barriers_time;
        window;
        mainPanel;
        sidePanel;
        settingPanel;
        statPanel;
        status;
        sub_window;
        infoPanel;
        info;
        player;
        player_print;
        playerStat;
        updateTimer; %定时器
        dispTimer;
        netTimer;
        sendTimer;
        sendTimerOn;
        pauseTimer;
        timers;
        dt;
        vPeriod;
        paused;
        keyQueue;
        Stat;
        count;
        fpsCount;
        counting;
        socket;
    end
    methods 
        function obj = World(dt,dispPeriod)
            obj.init_v = -3;%自定义栅栏初始速度
            obj.velocity = obj.init_v;
            obj.width = 24;%自定义空间大小
            obj.height = 9;
            obj.barriers = {}; obj.barrier_prints = {};
            obj.initWindow();
            
            obj.initWidgets();
            set(obj.sub_window,'NextPlot','add');
            obj.player = Box([3,11],2,2,'g',obj.sub_window); %customize the player
            obj.playerStat = struct('jump',0,'squat',0);
            obj.player_print = obj.player.draw(); %获取玩家对象用于可视化的数据

            set(obj.sub_window,'NextPlot','replace');
            set(obj.sub_window,'xlim',[0,obj.width]);
            set(obj.sub_window,'ylim',[0,obj.height]);

            obj.time = 0;
            obj.place_barriers_time = obj.time + 1;
            obj.dt = dt;
            obj.vPeriod = dispPeriod;
            obj.initUpdateTimer(dt);
            obj.initDispTimer(dispPeriod);
            obj.initNetTimer(0.01);
            obj.initSendTimer(1);
            obj.sendTimerOn = false;
            obj.initPauseTimer(1);
            obj.socket.fd = [];
            obj.timers = [obj.updateTimer, obj.dispTimer];
            start(obj.timers);

            obj.paused = 0;
            disp("finished");
            obj.Stat = 'running';
            obj.counting = 0;
        end

        function update(obj,~,evt)
        %myFun - Description
        %
        % Syntax: myFun(input)
        %
        % update the world
            obj.keyPressHandle();
            if obj.paused == 1

            else
                obj.time = obj.time+obj.dt;
                if ~isempty(obj.barriers) && (obj.barriers{1}.displacement < 0)
                    delete(obj.barrier_prints{1});
                    delete(obj.barriers{1});
                    obj.barriers(1) = [];
                    obj.barrier_prints(1) = [];
                end
                if obj.time - obj.place_barriers_time > 0
                    obj.barriers{end+1} = Barrier([2+2*rand,0,obj.width],obj.sub_window);
                    set(obj.sub_window,'NextPlot','add');
                    obj.barrier_prints{end+1} = obj.barriers{end}.draw();
                    set(obj.sub_window,'NextPlot','replace');
                    obj.place_barriers_time = obj.time + 1.7 + rand;%定义出栅栏的时间间隔
                    obj.velocity = obj.velocity - 10*obj.dt; %定义每出一个栅栏速度的增加
                end

                for i = 1:length(obj.barriers)
                    obj.barriers{i}.move(obj.velocity*obj.dt);
                end
                if obj.player.state == 0 && obj.playerStat.jump == 1 % jumping detector
                        obj.player.v = 11;
                end
                if obj.playerStat.squat == 1 % squat detector
                    obj.player.target(2) = 1/3;
                else
                    obj.player.target(2) = 1;
                end
                obj.player.update(-15,obj.dt);%第一个参数为重力加速度
                if obj.iscollision()
                    disp(['Game over. t = ', num2str(obj.time)]);
                    obj.Pause();
                    obj.visualize();
                    obj.Stat = 'gameover';
                    set(obj.info.gameover,'String','GAMEOVER');
                    disp('Press R to restart');
                end
            end
        end
        function result = iscollision(obj)
        %myFun - Description
        %
        % Syntax: output = myFun(input)
        %
        % collision detector
            result = false;
            yp = obj.player.center(2)-obj.player.current(2);
            xp1 = obj.player.center(1)-obj.player.current(1);
            xp2 = obj.player.center(1)+obj.player.current(1);
            for i = 1:length(obj.barriers)
                b = obj.barriers{i};
                if b.displacement > xp2 
                    break;
                end
                if yp < b.len && xp1 < b.displacement && xp2 > b.displacement
                    result = true;
                end
            end
        end
        function visualize(obj,~,~)
        % 可视化
            %渲染栅栏
            for i = 1:length(obj.barriers)
                p = obj.barrier_prints{i};
                pla = obj.barriers{i}.displacement;
                set(p,'xdata',[pla, pla]);
            end
            %渲染玩家
            ps = obj.player.get_points();
            set(obj.player_print.frame,'Vertices',ps.frame);
            for i = 1:length(ps.pattern)
                set(obj.player_print.pattern{i},'xdata',ps.pattern{i}(1,:));
                set(obj.player_print.pattern{i},'ydata',ps.pattern{i}(2,:));
            end
            %update info displayed
            obj.info.score = ['Score: ', num2str(obj.time)];
            set(obj.info.panel,'String',obj.info.score);
            obj.fpsCount = obj.fpsCount + 1;
            if obj.fpsCount==30
                set(obj.count,'String',[num2str(round(1/obj.dispTimer.InstantPeriod)),'FPS']);
                obj.fpsCount = 0;
            end
            set(obj.status.playerStat,'String',['jump:',num2str(obj.playerStat.jump),...
            '   squat:',num2str(obj.playerStat.squat)]);
        end

        function reset(obj,~,~)
            % reset the world
            obj.counting = 0;
            obj.keyQueue = [];
            stop(obj.timers);
            obj.velocity = obj.init_v;
            for i = 1:length(obj.barriers)
                delete(obj.barrier_prints{i});
                delete(obj.barriers{i});
            end
            delete(obj.player_print.frame);
            for i = 1:length(obj.player_print.pattern)
                delete(obj.player_print.pattern{i});
            end
            set(obj.sub_window,'NextPlot','add');
            obj.barriers = {} ;obj.barrier_prints = {};
            obj.player = Box([4,10],2,2,'g',obj.sub_window); %customize the player
            obj.player_print = obj.player.draw();

            set(obj.sub_window,'xlim',[0,obj.width]);
            set(obj.sub_window,'ylim',[0,obj.height]);
            set(obj.sub_window,'NextPlot','replace');
            obj.time = 0;
            obj.place_barriers_time = obj.time + 1;

            obj.Stat = 'running';
            %重置定时器
            delete(obj.timers);
            obj.initUpdateTimer(obj.dt);
            obj.initDispTimer(obj.vPeriod);
            obj.timers = [obj.updateTimer, obj.dispTimer];
            start(obj.timers);
            obj.paused = 0;
            set(obj.count,'String','');
            set(obj.info.gameover,'String','');
        end

        function initUpdateTimer(obj,period)
        %initUpdateTimer - Description
        %
        % Syntax: initUpdateTimer(period)
        %
        % initialize the UpdateTimer, called by the constructor
            obj.updateTimer = timer;
            obj.updateTimer.ExecutionMode = 'fixedRate';
            obj.updateTimer.TimerFcn = @obj.update;
            obj.updateTimer.period = period;
        end

        function initDispTimer(obj,period)
        %initDispTimer - Description
        %
        % Syntax: initDispTimer(period)
        %
        % initialize the DispTimer, called by the constructor
            obj.dispTimer = timer;
            obj.dispTimer.ExecutionMode = 'fixedRate';
            obj.dispTimer.TimerFcn = @obj.visualize;
            obj.dispTimer.period = period;
            obj.fpsCount = 0;
        end

        function initNetTimer(obj,period)
        %initNetTimer - Description
        %
        % Syntax: initNetTimer(period)
        %
        % initialize the NetTimer, called by the constructor
            obj.netTimer = timer;
            obj.netTimer.ExecutionMode = 'fixedRate';
            obj.netTimer.TimerFcn = @obj.readSocket;
            obj.netTimer.period = period;
        end
        function readSocket(obj,~,~)
        % 从后台读取信息并执行任务
            if ~isempty(obj.socket.fd) && obj.socket.fd.BytesAvailable > 0
                disp(obj.socket.fd.BytesAvailable);
                data = obj.socket.fd.read(1);
                switch data
                case '~'
                    header = obj.socket.fd.read(3); %type|frameLen|batchs
                    switch header(1)
                    case 'k'
                        keyData = obj.socket.fd.read(1);
                        switch keyData
                        case 'r'
                            obj.reset();
                            return;
                        case 'l'
                            obj.Pause();
                            return;
                        end
                        obj.keyQueue(end+1) = keyData;
                    case 's'
                        sdata = obj.socket.fd.read(header(2));
                        for i = 1:header(3)
                            key = sdata(2*i-1);
                            val = sdata(2*i);
                            obj.setFromBg(key,double(val));
                        end
                    end
                end
                obj.socket.fd.read();
            end
        end
        function initPauseTimer(obj,period)
            %initPauseTimer - Description
            %
            % Syntax: initPauseTimer(period)
            %
            % initialize the PauseTimer, called by the constructor
                obj.pauseTimer = timer;
                obj.pauseTimer.ExecutionMode = 'fixedRate';
                obj.pauseTimer.TimerFcn = @obj.pauseCount;
                obj.pauseTimer.StopFcn = @obj.pauseDone;
                obj.pauseTimer.TasksToExecute = 4;
                obj.pauseTimer.period = period;
            end
        function pauseCount(obj,~,~)
            set(obj.count,'String',num2str(4-obj.pauseTimer.TasksExecuted));
        end
        function pauseDone(obj,~,~)
            set(obj.count,'String','');
            obj.paused = 0;
            start(obj.timers);
            obj.counting = 0;
        end
        function initSendTimer(obj,period)
            %initSendTimer - Description
            %
            % Syntax: obj.initSendTimer(period)
            %
            % initialize the SendTimer, called by the constructor
                obj.sendTimer = timer;
                obj.sendTimer.ExecutionMode = 'fixedRate';
                obj.sendTimer.TimerFcn = @obj.sendStatus;
                obj.sendTimer.period = period;
            end
        function sendStatus(obj,~,~)
            write(obj.socket.fd,uint8(['~','d',60,4])); %header
            switch obj.Stat(1)
            case 'r'
                stat = 0;
            case 'g'
                stat = 1;
            end
            write(obj.socket.fd,obj.time);
            write(obj.socket.fd,uint8([stat,obj.playerStat.jump,obj.playerStat.squat]));
            displacement = zeros([1,3]);
            len = zeros([1,3]);
            if ~isempty(obj.barriers)
                for i = 1:length(obj.barriers)
                    displacement(i) = obj.barriers{i}.displacement;
                    len(i) = obj.barriers{i}.len;
                end
            end
            write(obj.socket.fd,[displacement,len]);
            write(obj.socket.fd,uint8('!'));

            if strcmp(obj.Stat,'gameover')
                write(obj.socket.fd,uint8('r'));
            end
        end
        function initWindow(obj)
        %initWindow - Description
        %
        % initialize the mainwindow
            obj.window = figure('name','Jump over bars',...
            'MenuBar','none','NumberTitle','off');
            set(obj.window,'Position',[100 100 1300 500]);%自定义窗口大小
            set(obj.window,'CloseRequestFcn',@obj.exit);
            set(obj.window,'KeyPressFcn',@obj.addKey);
            set(obj.window,'KeyReleaseFcn',@obj.keyRelease);
        end
        function initMenuWidget(obj)
        %initMenuWidget - Description
        %
        % initialize the menu
            obj.sidePanel = uipanel(obj.window,'Position',[.80,.05,.20,.95],...
            'Title','Menu','FontSize',12,'TitlePosition','centertop');
            % side panel
            uicontrol(obj.sidePanel,'String','PAUSE','fontsize',12,...
            'Callback',@obj.Pause,...
            'Units','normalized',...
            'Position',[.1,.8,.8,.1]);
            uicontrol(obj.sidePanel,'String','RESTART','fontsize',12,...
            'Callback',@obj.reset,...
            'Units','normalized',...
            'Position',[.1,.6,.8,.1]);
            uicontrol(obj.sidePanel,'String','SETTINGS','fontsize',12,...
            'Callback',@obj.openSetting,...
            'Units','normalized',...
            'Position',[.1,.4,.8,.1]);
            uicontrol(obj.sidePanel,'Style','text','fontsize', 12,...
            'String','[-----Connection-----]',...
            'Units','normalized',...
            'Position',[.1,.32,.8,.05]);
            obj.socket.address = uicontrol(obj.sidePanel,'Style','edit','String','localhost','fontsize',10,...
            'Units','normalized',...
            'Position',[.4,.25,.5,.05]);
            uicontrol(obj.sidePanel,'Style','text','fontsize', 10,'String','Address:',...
            'HorizontalAlignment','left',...
            'Units','normalized',...
            'Position',[.1,.25,.3,.05]);
            obj.socket.port = uicontrol(obj.sidePanel,'Style','edit','String','8888','fontsize',10,...
            'Units','normalized',...
            'Position',[.4,.15,.5,.05]);
            uicontrol(obj.sidePanel,'Style','text','fontsize', 10,'String','Port:',...
            'HorizontalAlignment','left',...
            'Units','normalized',...
            'Position',[.1,.15,.3,.05]);
            uicontrol(obj.sidePanel,'String','CONNECT','fontsize',8,...
            'Callback',@obj.connect,...
            'Units','normalized',...
            'Position',[.1,.02,.35,.1]);
            uicontrol(obj.sidePanel,'String','DISCONNECT','fontsize',8,...
            'Callback',@obj.disconnect,...
            'Units','normalized',...
            'Position',[.55,.02,.35,.1]);
        end
        function initSettingWidget(obj)
        %initSettingWidget - Description
        %
        % initialize the settings menu
            obj.settingPanel = struct;
            obj.settingPanel.panel = uipanel(obj.window,'Position',[.80,.05,.20,.95],...
            'Title','Settings','FontSize',12,'TitlePosition','centertop');
            % setting panel
            panel = obj.settingPanel.panel;
            uicontrol(panel,'Style','text','String','Frames per Second(HZ):','fontsize',12,...
            'HorizontalAlignment','left','Units','normalized',...
            'Position',[.1,.8,.8,.05]);
            obj.settingPanel.fps = uicontrol(panel,'Style','popupmenu','fontsize',10,...
            'Units','normalized','Position',[.1,.75,.8,.05],...
            'String',{'10','20','30','45','60'},'Value',5,...
            'Callback',@obj.settingChanged);
            uicontrol(panel,'Style','text','String','Simulation Rate(HZ):','fontsize',12,...
            'HorizontalAlignment','left','Units','normalized',...
            'Position',[.1,.65,.8,.05]);
            obj.settingPanel.rate = uicontrol(panel,'Style','popupmenu','fontsize',10,...
            'Units','normalized','Position',[.1,.6,.8,.05],...
            'String',{'10','20','30','45','60','120'},'Value',6,...
            'Callback',@obj.settingChanged);
            obj.settingPanel.message = uicontrol(panel,'Style','text','String','','fontsize',12,...
            'Units','normalized',...
            'Position',[.1,.2,.8,.05]);
            uicontrol(panel,'String','APPLY','fontsize',8,...
            'Callback',@obj.applSettings,...
            'Units','normalized',...
            'Position',[.1,.02,.35,.1]);
            uicontrol(panel,'String','BACK','fontsize',8,...
            'Callback',@obj.backToMenu,...
            'Units','normalized',...
            'Position',[.55,.02,.35,.1]);
            obj.settingPanel.applied = false;
            obj.settingPanel.fpsValue = 3;
            obj.settingPanel.rateValue = 5;
            obj.backToMenu();
        end
        function backToMenu(obj,~,~)
            if ~obj.settingPanel.applied
                set(obj.settingPanel.fps,'Value',obj.settingPanel.fpsValue);
                set(obj.settingPanel.rate,'Value',obj.settingPanel.rateValue);
            end
            set(obj.settingPanel.panel,'Visible','off');
        end
        function openSetting(obj,~,~)
            if obj.paused == 0
                obj.Pause()
            end
            set(obj.settingPanel.message,'String','');
            set(obj.settingPanel.panel,'Visible','on');
        end
        function applSettings(obj,~,~)
        % apply new settings
            rate = obj.settingPanel.rate;
            obj.settingPanel.rateValue = rate.Value;
            rate = rate.String{rate.Value};
            rate = str2double(rate);
            fps = obj.settingPanel.fps;
            obj.settingPanel.fpsValue = fps.Value;
            fps = fps.String{fps.Value};
            fps = str2double(fps);
            f2dt = @(x)floor(1000*(1/x))/1000;
            obj.updateTimer.period = f2dt(rate);
            obj.dispTimer.period = f2dt(fps);
            obj.dt = f2dt(rate);
            obj.vPeriod = f2dt(fps);
            obj.settingPanel.applied = true;
            set(obj.settingPanel.message,'String','Applied!');
        end
        function settingChanged(obj,~,~)
            obj.settingPanel.applied = false;
            set(obj.settingPanel.message,'String','');
        end
        function setFromBg(obj,key,val)
        % configure settings
            if obj.paused == 0
                obj.Pause();
            end
            switch key
            case 'f' % configure fps
                f2dt = @(x)floor(1000*(1/x))/1000;
                obj.dispTimer.period = f2dt(val);
                obj.vPeriod = f2dt(val);
            case 'r' % configure simulation rate
                f2dt = @(x)floor(1000*(1/x))/1000;
                obj.updateTimer.period = f2dt(val);
                obj.dt = f2dt(val);
            case 'c' % configure data sending rate
                if obj.sendTimerOn
                    stop(obj.sendTimer);
                    obj.sendTimerOn = false;
                end
                f2dt = @(x)floor(1000*(1/x))/1000;
                obj.sendTimer.period = f2dt(val);
            case 's' % whether to send data
                switch val
                case 0
                    if obj.sendTimerOn
                        stop(obj.sendTimer);
                        obj.sendTimerOn = false;
                    end
                case 1
                    if ~obj.sendTimerOn
                        start(obj.sendTimer);
                        obj.sendTimerOn = true;
                    end
                end
            end
            obj.Pause();
            obj.Pause();
        end
        function initWidgets(obj)
        %initWidgets - Description
        %
        % initialize the widgets
            % main panel
            obj.mainPanel = uipanel(obj.window,'Position',[.0,.05,.80,.95]);
            obj.sub_window = axes(obj.mainPanel,...
            'Position',[0,0,1,.9],...
            'Units','normalized',...
            'XTick',[],...
            'YTick',[]);
            set([obj.sub_window.XAxis,obj.sub_window.YAxis],'Visible','off');
            
            obj.initMenuWidget();
            obj.initSettingWidget();
            % info panel
            obj.infoPanel = uipanel(obj.mainPanel,'Position',[0,.9,1,.1]);
            obj.info = struct('panel',uicontrol(obj.infoPanel,'Style','text','HorizontalAlignment','left',...
            'fontsize',12,...
            'Units','normalized',...
            'Position',[0,0,.2,.8]),...
            'score',0,...
            'gameover',uicontrol(obj.infoPanel,'Style','text','fontsize',20,...
            'Units','normalized','Position',[.4,0,.2,1])...
            );
            obj.count = uicontrol(obj.infoPanel,'Style','text','fontsize', 20,...
            'Units','normalized',...
            'Position',[.8,0,.2,1]);

            % state panel
            obj.statPanel = uipanel(obj.window,'Position',[.0,.0,1,.05]);
            obj.status = struct;
            obj.status.playerStat = uicontrol(obj.statPanel,'Style','text','fontsize',10,...
            'HorizontalAlignment','left','Units','normalized','Position',[0,0,.2,1]);
            obj.status.conStat = uicontrol(obj.statPanel,'Style','text','fontsize',10,...
            'HorizontalAlignment','right','Units','normalized','Position',[.8,0,.2,1]);

        end

        function Pause(obj,~,~)
        % pause the game
            if strcmp(obj.Stat,'running') == 1
                switch obj.paused
                case 0
                    stop(obj.timers);
                    obj.paused = 1;
                    set(obj.count,'String','PAUSED');
                case 1
                    if obj.counting == 0
                        start(obj.pauseTimer);
                        obj.counting = 1;
                    else
                        stop(obj.pauseTimer);
                        obj.counting = 0;
                    end
                end
            end
        end
        function addKey(obj,~,evt)
            % insert a key press to the key queue
            switch evt.Key
            case 'r'
                obj.reset();
            case 'l'
                obj.Pause();
            otherwise
                if isempty(obj.keyQueue)
                    obj.keyQueue(end+1) = evt.Key;
                end
            end
        end
        function keyPressHandle(obj)
        % 每次更新时处理按键队列
            if ~isempty(obj.keyQueue)
                switch obj.keyQueue(1)
                case 'j'
                    obj.playerStat.jump = 1;
                case 'k'
                    obj.playerStat.squat = 1;
                case 'n'
                    obj.playerStat.jump = 0;
                case 'm'
                    obj.playerStat.squat = 0;
                end
                obj.keyQueue = [];
            end
        end
        function keyRelease(obj,~,evt)
        % 要立即相应的按键释放事件
            switch evt.Key
            case 'j'
                obj.playerStat.jump = 0;
            case 'k'
                obj.playerStat.squat = 0;
            end
            obj.keyQueue = [];
        end
        function connect(obj,~,~)
            % 连接至后台
            if isempty(obj.socket.fd)
                set(obj.status.conStat,'String','connecting...');
                try
                    obj.socket.fd = tcpclient(...
                    obj.socket.address.String,...
                    str2double(obj.socket.port.String),...
                    'ConnectTimeout',1);
                catch
                    disp('Fail to connect to background');
                    obj.socket.fd = [];
                end  
            else
                disp("connected");
                return;
            end
            if isempty(obj.socket.fd)
                disp("con failed");
                set(obj.status.conStat,'String','disconnected');
            else
                disp("con successfully");
                set(obj.status.conStat,'String','connected');
                obj.netTimer.start();   
            end
        end
        function disconnect(obj,~,~)
            % 断开与后台的连接
            if ~isempty(obj.socket.fd)
                stop([obj.netTimer,obj.sendTimer]);
                delete(obj.socket.fd);
                obj.socket.fd = [];
                disp("disconnected");
                set(obj.status.conStat,'String','disconnected');
                obj.playerStat.jump = 0;
                obj.playerStat.squat = 0;
            end
        end
        function exit(obj,fig,~)
        % 退出游戏对话框
            if obj.paused == 0
                obj.Pause();
            end
            q = questdlg('Exit the game?','Exit','Yes','No','No');
            if strcmp(q,'Yes')
                delete(fig);
                exit();
            end
        end
    end
    methods (Static)
        
    end
end