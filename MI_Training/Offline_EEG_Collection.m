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
%system('F:\CASIA\mwl_data_collection\climbstair\ClimbStair3.exe&');      % Unity动画exe文件地址
%system('E:\MI_engagement\unity_test\unity_test\build_test\unity_test.exe&');
system('E:\UpperLimb_Animation\unity_test.exe&');
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
subject_name = 'FS_test';  % 被试姓名
TrialNum = 30*3;  % 设置采集的数量
%TrialNum = 3*3;
MotorClasses = 3;  % 运动想象的种类的数量的设置，注意这里是把空想idle状态也要放进去的，注意这里的任务是[0,1,2]，和readme.txt里面的对应

% 脑电设备的数据采集
sample_frequency = 256; 
WindowLength = 512;  % 每个窗口的长度
channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道
mu_channels = struct('C3',1, 'C4',2);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
EI_channels = struct('Fp1', 1, 'Fp2', 2, 'F7', 3, 'F3', 4, 'Fz', 5, 'F4', 6, 'F8', 7);  % 用于计算EI指标的几个channels，需要确定下位置的
weight_mu = 0.6;  % 用于计算ERD/ERS指标和EI指标的加权和

% 通信设置
ip = '172.18.22.21';
port = 8888;  % 和后端服务器连接的两个参数

%% 运动想象内容安排
TrialIndex = randperm(TrialNum);                                           % 根据采集的数量生成随机顺序的数组
%All_data = [];
Trigger = 0;                                                               % 初始化Trigger，用于后续的数据存储
AllTrial = 0;

randomindex = [];                                                          % 初始化trials的集合
for i= 0:(MotorClasses-1)
    index_i = ones(TrialNum/MotorClasses,1)*i;                             % size TrialNum/MotorClasses*1，各种任务
    randomindex = [randomindex; index_i];                                  % 各个任务整合，最终size TrialNum*1
end

RandomTrial = randomindex(TrialIndex);                                     % 随机生成各个Trial对应的任务

%% 实验数据采集存储设置
% 设置相关参数
classes = MotorClasses;
foldername = ['.\\', FunctionNowFilename([subject_name, '_'], '_data')]; % 指定文件夹路径和名称

if ~exist(foldername, 'dir')
   mkdir(foldername);
end
% 设置存储score的数组
scores = [];  % 用于存储每一个trial里面的每一个window的分数值
EI_indices = [];  % 用于存储每一个trial里面的每一个window的EI分数值
mu_powers = [];  % 用于存储每一个trial里面的每一个window的mu频带的能量数值
scores_task = [];  % 用于存储score和task

%% 开始实验，离线采集
Timer = 0;
TrialData = [];
while(AllTrial <= TrialNum)
    if Timer==0  %提示专注 cross
        Trigger = 6;
        sendbuf(1,1) = hex2dec('01') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);       
        AllTrial = AllTrial + 1;
    end
    
    if Timer==2
        Trigger = RandomTrial(AllTrial);  % 播放动作的AO动画（Idle, MI1, MI2）
        mat2unity = ['0', num2str(Trigger + 3)];
        sendbuf(1,1) = hex2dec(mat2unity) ;
        sendbuf(1,2) = hex2dec('01') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);
        rawdata = TrialData(:,end-512+1:end);  % 取前一个512的窗口
        rawdata = rawdata(2:end,:);
        % 这里仅仅提取在MI之前的频带能量
        [~, ~, mu_power_] = Online_DataPreprocess(rawdata, 6, sample_frequency, WindowLength, channels);
        mu_power_ = [mu_power_; Trigger];
        mu_powers = [mu_powers, mu_power_];  % 添加相关的mu节律能量
    end
    
    % 第4s开始取512的Trigger~=6的MI的窗口，数据处理并且进行分析
    if Timer > 3 && Timer <= 7
        rawdata = TrialData(:,end-512+1:end);  % 取前一个512的窗口
        rawdata = rawdata(2:end,:);
        
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess(rawdata, Trigger, sample_frequency, WindowLength, channels);
        % mu_suppression = (mu_power_MI(mu_channel,1) - mu_power_(mu_channel,1))/mu_power_(mu_channel,1);  % 计算miu频带衰减情况
        % 计算两个指标
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % 计算得分
        scores = [scores, score];  % 保存得分
        scores_task_ = [score; Trigger];
        scores_task = [scores_task, scores_task_];  % 保存分数-任务对，用于后续的分析任务难度用的
        % 存储这两个指标的数值
        EI_index = [EI_index; Trigger];
        mu_power_MI = [mu_power_MI; Trigger];  % 这里添加上Trigger的相关数值，方便存储
        
        EI_indices = [EI_indices, EI_index];  % 添加相关的EI指标数值，用于后续的分析  
        mu_powers = [mu_powers, mu_power_MI];  % 添加相关的mu节律能量，用于后续的分析

    end
    
    if Timer==7  %开始休息
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
    end
    
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
    
    if Timer == 10
        Timer = 0;  % 计时器清0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(RandomTrial(AllTrial))]);  % 显示相关数据
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % 计算得分
    end
    
end
%% 存储原始数据
close all
TrialData = TrialData(2:end,:);  %去掉矩阵第一行
ChanLabel = flip({infoList.chanLabel});
pnet('closeall')   % 将连接关闭
% 存储原始数据
foldername_rawdata = [foldername, '\\Offline_EEGMI_RawData_', subject_name]; % 指定文件夹路径和名称
if ~exist(foldername_rawdata, 'dir')
   mkdir(foldername_rawdata);
end
save([foldername_rawdata, '\\', FunctionNowFilename(['Offline_EEGMI_RawData_', subject_name], '.mat' )],'scores_task','EI_indices','mu_powers');

%% 数据预处理
% 划窗参数设置
rawdata = TrialData;
sample_frequency = 256; 
WindowLength = 512;  % 每个窗口的长度
SlideWindowLength = 256;  % 滑窗间隔
[DataX, DataY, windows_per_session] = Offline_DataPreprocess(rawdata, classes, sample_frequency, WindowLength, SlideWindowLength, channels, subject_name, foldername);

%% 预处理数据传输
% 设置传输的参数
send_order = 3.0;
config_data = [WindowLength, size(channels, 2), windows_per_session, classes];
Offline_Data2Server_Send(DataX, ip, port, subject_name, config_data, send_order, foldername);

%% 每一种任务对应的scores平均分数确定，并且存储相关指标
foldername_Scores = [foldername, '\\Offline_EEGMI_Scores_', subject_name]; % 指定文件夹路径和名称
if ~exist(foldername_Scores, 'dir')
   mkdir(foldername_Scores);
end
save([foldername_Scores, '\\', FunctionNowFilename(['Offline_EEGMI_Scores_', subject_name], '.mat' )],'TrialData','TrialIndex','ChanLabel');
compute_mean_scores(scores_task);  % 计算并且显示难度

function mean_scores = compute_mean_scores(scores_task)
    % 获取scores和triggers
    scores = scores_task(1,:);
    triggers = scores_task(2,:);

    % 获取所有不同的triggers
    unique_triggers = unique(triggers);

    % 初始化输出
    mean_scores = zeros(size(unique_triggers));

    % 对于每一个trigger，计算对应的score的均值
    for i = 1:length(unique_triggers)
        trigger = unique_triggers(i);
        mean_scores(i) = mean(scores(triggers == trigger));
    end

    % 输出结果
    disp('Trigger的平均分数是：');
    for i = 1:length(unique_triggers)
        disp(['Trigger ' num2str(unique_triggers(i)) ' 的平均分数是 ' num2str(mean_scores(i))]);
    end
end
%% 计算相关mu频带衰减指标
    function mu_suppresion = MI_MuSuperesion(mu_power_, mu_power, mu_channels)
        ERD_C3 = (mu_power(mu_channels.C3, 1) - mu_power_(mu_channels.C3, 1))/mu_power_(mu_channels.C3, 1); 
        ERD_C4 = (mu_power(mu_channels.C4, 1) - mu_power_(mu_channels.C4, 1))/mu_power_(mu_channels.C4, 1);  % 计算两个脑电位置的相关的指标 
        mu_suppresion = abs(ERD_C4 - ERD_C3);
    end
    
    %% 计算相关的EI指标的函数
    function EI_index_score = EI_index_Caculation(EI_index, EI_channels)
        channels_ = [EI_channels.Fp1,EI_channels.Fp2, EI_channels.F7, EI_channels.F3, EI_channels.Fz, EI_channels.F4, EI_channels.F8'];
        EI_index_score = mean(EI_index(channels_, 1));
        
    end