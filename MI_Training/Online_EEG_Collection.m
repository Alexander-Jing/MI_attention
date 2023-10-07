%% 初始化，关闭所有连接
pnet('closeall');
clc;
clear;
close all;
%% 启动Unity程序，并初始化
% 程序说明：发送命令共5字节
%           Byte1：画面/动作切换
%           Byte2：控制画面是否运动
%           Byte3：画面文字显示（离线训练实验无文字提示）
%           Byte4：动作类型
%           Byte5：预留
%system('F:\CASIA\mwl_data_collection\climbstair\ClimbStair3.exe&');       % Unity动画exe文件地址
system('E:\MI_engagement\unity_test\unity_test\build_test\unity_test.exe&');
pause(3)
UnityControl = tcpip('localhost', 8881, 'NetworkRole', 'client');          % 新的端口改为8881
fopen(UnityControl);
pause(1)
sendbuf = uint8(1:5);
sendbuf(1,1) = hex2dec('00') ;
sendbuf(1,2) = hex2dec('00') ;
sendbuf(1,3) = hex2dec('00') ;
sendbuf(1,4) = hex2dec('00') ;
sendbuf(1,5) = hex2dec('00') ;
fwrite(UnityControl,sendbuf);
pause(3)

%% 设置脑电采集参数
init = 0;
freq = 256;
startStop = 1;
con = pnet('tcpconnect','127.0.0.1',4455);                                 % 建立一个连接
status = CheckNetStreamingVersion(con);                                    % 判断版本信息，正确返回状态值为1
[~, basicInfo] = ClientGetBasicMessage(con);                               % 获取设备基本信息basicInfo包含 size,eegChan,sampleRate,dataSize
[~, infoList] = ClientGetChannelMessage(con,basicInfo.eegChan);            % 获取通道信息
%% 在线实验参数设置部分，用于设置每一个被试的情况，依据被试情况进行修改

% 运动想象基本参数设置
subject_name = 'Jyt';  % 被试姓名
session_idx = 1;  % session index数量，如果是1的话，会自动生成相关排布
MotorClass = 2; % 运动想象动作数量，注意这里是纯设计的运动想象动作的数量，不包括空想idle状态
DiffLevels = [2,1];  % 对于上面的运动想象的难度排布，越靠后越难，其中的1,2对应的是运动想象的类型，和unity对应
MajorPoportion = 0.6;  % 每一个session里面不同类型运动想象总数所占的比值
TrialNum = 40;  % 每一个session里面的trial的数量

% 运动想象任务调整设置
MaxMITime = 30; % 在线运动想象最大允许时间 
sample_frequency = 256; 
WindowLength = 512;  % 每个窗口的长度
channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道
mu_channel = 14;  % 用于计算ERD/ERS的几个channels，需要确定下位置的
EI_channel = 10;  % 用于计算EI指标的几个channels，需要确定下位置的
weight_mu = 0.6;  % 用于计算ERD/ERS指标和EI指标的加权和

% 通信设置
ip = '172.18.22.21';
port = 8888;  % 和后端服务器连接的两个参数

%% 准备初始的存储数据的文件夹
foldername = ['.\\', FunctionNowFilename([subject_name, '_'], '_data')]; % 指定文件夹路径和名称
if ~exist(foldername, 'dir')
   mkdir(foldername);
end

%% 生成任务安排调度
Trigger = 0;                                                               % 初始化Trigger，用于后续的数据存储
AllTrial = 0;

if session_idx == 1  % 如果是第一个session，那需要生成相关的任务集合
    Level2task(MotorClass, MajorPoportion, TrialNum, DiffLevels, foldername, subject_name);
    path = [foldername, '\\', 'Level2task', '_', subject_name, '\\', 'Online_EEGMI_session_', num2str(session_idx), '_', subject_name, '.mat'];
    ChoiceTrial = load(path,'session');
else
    path = [foldername, '\\', 'Level2task', '_', subject_name, '\\', 'Online_EEGMI_session_', num2str(session_idx), '_', subject_name, '.mat'];
    ChoiceTrial = load(path,'session');
end

ChoiceTrial = ChoiceTrial.session;
%% 开始实验，离线采集
Timer = 0;
TrialData = [];
scores = [];  % 用于存储每一个trial里面的分数值
scores_trial = [];  % 用于存储每一个trial的平均分数值
clsFlag = 0; % 用于判断实时分类是否正确的flag
Trials = [];
Trials = [Trials, ChoiceTrial(1,1)];  % 初始化RandomTrial，第一个数值是ChoiceTrial任务集合中的第一个
while(AllTrial <= TrialNum)
    %% 提示专注阶段
    if Timer==0  %提示专注 cross
        Trigger = 6;
        sendbuf(1,1) = hex2dec('01') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);       
        AllTrial = AllTrial + 1;
    end
    
    %% 运动想象阶段
    if Timer==2
        if Trials(AllTrial)==0  % 空想任务
            Trigger = 1;
            sendbuf(1,1) = hex2dec('03') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        if Trials(AllTrial)> 0  % 运动想象任务
            Trigger = RandomTrial(AllTrial);  % 播放动作的AO动画（Idle, MI1, MI2）
            mat2unity = ['0', num2str(Trigger + 3)];
            sendbuf(1,1) = hex2dec(mat2unity) ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % 第2s的时候，取512的Trigger==6的窗口，数据处理并且进行分析
        rawdata = TrialData(:,end-512+1:end);  % 取前一个512的窗口
        rawdata = rawdata(2:end,:);
        % 这里仅仅提取在MI之前的频带能量
        [~, ~, mu_power_] = Online_DataPreprocess(rawdata, 6, sample_frequency, WindowLength, channels);  
    end
    
    % 第4s开始取512的Trigger~=6的MI的窗口，数据处理并且进行分析
    if Timer > 3 && Trials(AllTrial)> 0 && clsFlag == 0
        rawdata = TrialData(:,end-512+1:end);  % 取前一个512的窗口
        rawdata = rawdata(2:end,:);
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess(rawdata, Trials(AllTrial), sample_frequency, WindowLength, channels);
        mu_suppression = (mu_power_MI(1,mu_channel) - mu_power_(1,mu_channel))/mu_power_(1,mu_channel);  % 计算miu频带衰减情况
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index;  % 计算得分
        scores = [scores, score];  % 保存得分
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score;0;0;0;0 ];
        order = 1.0;
        resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data, foldername);  % 传输数据给线上的模型，看分类情况
        if resultMI == Trials(AllTrial)
            clsFlag = 1;  % 识别正确，置1
        else
            clsFlag = 0;
        end        
    end
    
   %% 运动想象给与反馈阶段（想对/时间范围内没有想对）,同时更新模型
   % 想对了开始播放动作 
   if clsFlag == 1 
        clsTime = Timer;  % 这是分类正确的时间
        if Trials(AllTrial) > 0  % 运动想象任务
            Trigger = RandomTrial(AllTrial);  % 播放动作的AO动画（Idle, MI1, MI2）
            mat2unity = ['0', num2str(Trigger + 3)];
            sendbuf(1,1) = hex2dec(mat2unity) ;
            sendbuf(1,2) = hex2dec('01') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % 传输数据和更新模型
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score;0;0;0;0 ];
        order = 2.0;  % 传输数据和训练的命令
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % 发送指令，让服务器更新数据，[0,0,0,0]单纯是用于凑下数据，防止应为空集影响传输
   end
    
    % 想错了开始休息和提醒
    if clsFlag == 0 && Timer == (MaxMITime + 2)
        clsTime = Timer;  % 这是分类正确的时间
        if Trials(AllTrial)==2  % 运动想象任务
            Trigger = 2;
            sendbuf(1,1) = hex2dec('02') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % 传输数据和更新模型
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score;0;0;0;0 ];
        order = 2.0;  % 传输数据和训练的命令
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % 发送指令，让服务器更新数据，[0,0,0,0]单纯是用于凑下数据，防止应为空集影响传输
    end
    
   %% 休息阶段，确定下一个动作
    % 空想只给5s就休息
    if Timer==7 && Trials(AllTrial)==0  %开始休息
        Trigger = 6;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % 更新算法
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score;0;0;0;0 ];
        order = 2.0;  % 传输数据和训练的命令
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % 发送指令，让服务器更新数据，[0,0,0,0]单纯是用于凑下数据，防止应为空集影响传输
        % 进入确定下一个任务
        average_score = average(scores);
        scores_trial = [scores_trial, average_score];  % 存储好平均的分数
        [Trials, ChoiceTrial] = TaskAdjust(scores_trial, ChoiceTrial, Trials, AllTrial, DiffLevels);
    end
    
    % 运动想象想对了之后，AO结束了之后让人休息
    if Timer == (clsTime + 5) && clsFlag == 1  %开始休息
        Trigger = 6;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % 进入确定下一个任务
        average_score = average(scores);
        scores_trial = [scores_trial, average_score];  % 存储好平均的分数
        [Trials, ChoiceTrial] = TaskAdjust(scores_trial, ChoiceTrial, Trials, AllTrial, DiffLevels);
    end
    % 运动想象没有想对，提醒结束了之后让人休息
    if clsFlag == 0 && Timer == (MaxMITime + 2 + 5)
        Trigger = 6;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % 进入确定下一个任务
        average_score = average(scores);
        scores_trial = [scores_trial, average_score];  % 存储好平均的分数
        [Trials, ChoiceTrial] = TaskAdjust(scores_trial, ChoiceTrial, Trials, AllTrial, DiffLevels);
    end
    
    %% 时钟更新
    % 生成标签
    TriggerRepeat = repmat(Trigger,1,256);  % 生成标签
    % 脑电信号采集
    tic
    pause(1);
    [~, data] = ClientGetDataPacket(con,basicInfo,infoList,startStop,init); % Obtain EEG data, 需要在ClientGetDataPacket设置要不要移除基线
    toc
    data = [data;TriggerRepeat];
    TrialData = [TrialData,data];
    Timer = Timer + 1;
    
    %% 最后的各个数值复位
    % 空想任务想象5s，到第7s之后开始休息，到第10s就结束任务
    if Timer == 10 && Trials(AllTrial)==0  %结束休息，准备下一个
        Timer = 0;  % 计时器清0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % 显示相关数据
    end
    % 想对了之后，AO之后，休息3s之后，结束休息，准备下一个
    if Timer == (clsTime + 5 + 3) && clsFlag == 1  %结束休息
        Timer = 0;  % 计时器清0
        clsFlag = 0;  % 分类flag清0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % 显示相关数据
    end
    
    % 运动想象没有想对，提醒之后，休息3s之后，结束休息，准备下一个
    if clsFlag == 0 && Timer == (MaxMITime + 2 + 5 + 3)
        Timer = 0;  % 计时器清0
        clsFlag = 0;  % 分类flag清0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % 显示相关数据
    end
end
%% 存储原始数据
close all
TrialData = TrialData(2:end,:);  %去掉矩阵第一行
ChanLabel = flip({infoList.chanLabel});
pnet('closeall')   % 将连接关闭
% 存储原始数据
foldername_rawdata = [foldername, '\\Online_EEGMI_RawData_', subject_name]; % 指定文件夹路径和名称
if ~exist(foldername_rawdata, 'dir')
   mkdir(foldername_rawdata);
end
save([foldername_rawdata, '\\', FunctionNowFilename(['Online_EEGMI_RawData_',str(session_idx), '_', subject_name], '.mat' )],'TrialData','Trials','ChanLabel');

%% 任务初始生成的函数
function Level2task(MotorClasses, MajorPoportion, TrialNum, DiffLevels, foldername, subject_name)  % MajorPoportion 每一个session中的主要动作的比例；TrailNum 每一个session中的trial数量, DiffLevels从低到高生成难度的矩阵，矩阵里的数值越高表示难度越高 
    
    foldername = [foldername, '\\', 'Level2task', '_', subject_name]; % 指定文件夹路径和名称
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end
    
    for SessionIndex = 1:MotorClasses  % 这里的SessionIndex也是主要难度对应的位置
        session = [];
        MotorMain = DiffLevels(1, SessionIndex);  % 主要成分的运动
        NumMain = round(TrialNum * MajorPoportion);  
        session = [session, repmat(MotorMain, 1, NumMain)];
        
        indices = find(DiffLevels==MotorMain);  % 找到MotorMain对应的index
        DiffLevels_ = DiffLevels;
        DiffLevels_(indices) = [];  % 去掉MotorMain的剩下的难度矩阵
        
        for i_=1:(MotorClasses - 1)
            MotorMinor = DiffLevels_(1, i_);  % 剩下的几个动作
            MinorProportion =  (1-MajorPoportion)/(MotorClasses - 1);  % 剩下动作的比重
            NumMinor = round(TrialNum * MinorProportion);
            session = [session, repmat(MotorMinor, 1, NumMinor)];  % 添加剩下的动作
        end    
        session = [session, repmat(0, 1, NumMinor)];  % 添加和剩下动作一致比例的空想动作
        path = [foldername, '\\', 'Online_EEGMI_session_', num2str(SessionIndex), '_', subject_name, '.mat'];
        save(path,'session');  % 存储相关数据，后面存储用
    end
    
end
%% 实时任务调度的函数
function [Trials, ChoiceTrial] = TaskAdjust(scores_trial, ChoiceTrial, Trials, AllTrial, DiffLevels)
    
    if AllTrial < 4  % 前4个trial由于无法进行数据采集，所以就先随机挑选
        n_ = length(ChoiceTrial);
        idx = randi(n_);  % 随机挑选的数值
        task_ = ChoiceTrial(1,idx);
        ChoiceTrial(1,idx) = [];  % 选择task_数值，以及在ChoiceTrial里面去掉这个选中的数值
        Trials = [Trials, task_];  % 更新Trials
    else
        % 接下来要写trial数量大于4的情况，要更具相关的scores分数情况来判定
        delta_score = scores_trial(end-2:end) - scores_trial(end-3,end-1);  % 计算出过去3个trial的分数变化
        delta_score(delta_score<=0) = -1;
        delta_score(delta_score>0) = 1;  % 对于delta_score的数值进行映射，映射的结果将方便后面的判断
        
        deltaSum_ = sum(delta_score);
        switch deltaSum_
            case 3
                % 如果此时是不断升高的，那么为了防止疲劳，会适当得调低难度
                currentTask_ = Trials(1, AllTrial);
                if currentTask_ > 0
                    diff_idx = find(DiffLevels, currentTask_);  % 确定当前的难度层级
                else
                    diff_idx = 0;
                end
                % 生成备选的难度
                diff_choice = [];
                if diff_idx > 1
                    diff_choice = [diff_choice, diff_idx-1:-1:1];  % 优先选择降一等级的难度, 其次选择所有低于此难度的数值
                    task_choice = DiffLevels(diff_choice);
                    task_choice = [task_choice, 0];  % 带上休息状态
                else
                    task_choice = [task_choice, 0];  % 带上休息状态
                end
                output_ = find_task_choice(task_choice, DiffLevels, 1);
                task_ = output_(1,1);
                
            case 1
                % 如果此时是升高多余降低的，那么还是增加任务难度
                currentTask_ = Trials(1, AllTrial);
                if currentTask_ > 0
                    diff_idx = find(DiffLevels, currentTask_);  % 确定当前的难度层级
                else
                    diff_idx = 0;
                end
                % 生成备选的难度
                diff_choice = [];
                diff_choice = [diff_choice, diff_idx+1:1:length(DiffLevels)];  % 优先选择升高一等级的难度, 其次选择所有低于此难度的数值
                task_choice = DiffLevels(diff_choice);
                output_ = find_task_choice(task_choice, DiffLevels, 0);
                task_ = output_(1,1);
                
            case -1
                % 如果此时是降低多余升高的，那么还是增加任务难度
                currentTask_ = Trials(1, AllTrial);
                if currentTask_ > 0
                    diff_idx = find(DiffLevels, currentTask_);  % 确定当前的难度层级
                else
                    diff_idx = 0;
                end
                % 生成备选的难度
                diff_choice = [];
                diff_choice = [diff_choice, diff_idx+1:1:length(DiffLevels)];  % 优先选择升高一等级的难度, 其次选择所有低于此难度的数值
                task_choice = DiffLevels(diff_choice);
                output_ = find_task_choice(task_choice, DiffLevels, 0);
                task_ = output_(1,1);
                
            case -3
                % 如果此时是不断降低的，那么为了防止疲劳，会适当得调低难度
                currentTask_ = Trials(1, AllTrial);
                if currentTask_ > 0
                    diff_idx = find(DiffLevels, currentTask_);  % 确定当前的难度层级
                else
                    diff_idx = 0;
                end
                % 生成备选的难度
                diff_choice = [];
                if diff_idx > 1
                    diff_choice = [diff_choice, diff_idx-1:-1:1];  % 优先选择降一等级的难度, 其次选择所有低于此难度的数值
                    task_choice = DiffLevels(diff_choice);
                    task_choice = [task_choice, 0];  % 带上休息状态
                else
                    task_choice = [task_choice, 0];  % 带上休息状态
                end
                output_ = find_task_choice(task_choice, DiffLevels, 1);
                task_ = output_(1,1);
                
        end
        % Trials里面添加任务
        Trials = [Trials, task_];
        % 任务集合ChoiceTrial里面删除任务
        index = find(ChoiceTrial == task_, 1);
        if ~isempty(index)
            ChoiceTrial(index) = [];
        end
    end
end


% 在DiffLevels中寻找特定任务的函数
function output = find_task_choice(task_choice, DiffLevels, add_flag)
    output = [];
    for i = 1:length(task_choice)
        if ismember(task_choice(i), DiffLevels)
            output = [output, task_choice(i)];
        end
    end
    if isempty(output)  % 如果找不到合适的任务，直接依据add_flag选择最大或者最小
        if add_flag
            output = [output, min(DiffLevels)];
        else
            output = [output, max(DiffLevels)];
        end
    end
end
