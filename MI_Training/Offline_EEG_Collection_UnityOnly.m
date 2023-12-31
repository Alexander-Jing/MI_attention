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
% init = 0;
% freq = 256;
% startStop = 1;
% con = pnet('tcpconnect','127.0.0.1',4455);                                 % 建立一个连接
% status = CheckNetStreamingVersion(con);                                    % 判断版本信息，正确返回状态值为1
% [~, basicInfo] = ClientGetBasicMessage(con);                               % 获取设备基本信息basicInfo包含 size,eegChan,sampleRate,dataSize
% [~, infoList] = ClientGetChannelMessage(con,basicInfo.eegChan);            % 获取通道信息

%% 实验相关参数设置
TrialNum = 10;                                                             % 设置采集的数量
TrialIndex = randperm(TrialNum);                                           % 根据采集的数量生成随机顺序的数组
All_data = [];
Trigger = 0;                                                               % 初始化Trigger，用于后续的数据存储
AllTrial = 0;

MotorClasses = 2;                                                          % 运动想象的种类的数量的设置
randomindex = [];                                                          % 初始化trials的集合
for i= 1:MotorClasses
    index_i = ones(TrialNum/MotorClasses,1)*i;                             % size TrialNum/MotorClasses*1，各种任务
    randomindex = [randomindex; index_i];                                  % 各个任务整合，最终size TrialNum*1
end

RandomTrial = randomindex(TrialIndex);                                     % 随机生成各个Trial对应的任务
%% 开始实验，离线采集
Timer = 0;
TrialData = [];
while(AllTrial <= TrialNum)
    if Timer==0  %提示专注 cross
        Trigger = 6;
        sendbuf(1,1) = hex2dec('03') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);       
        AllTrial = AllTrial + 1;
    end
    if Timer==2
        if RandomTrial(AllTrial)==1  % 空想任务
            Trigger = 1;
            sendbuf(1,1) = hex2dec('01') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        if RandomTrial(AllTrial)==2  % 运动想象任务
            Trigger = 2;
            sendbuf(1,1) = hex2dec('02') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
    end
    if Timer==10  %开始休息
        Trigger = 6;
        sendbuf(1,1) = hex2dec('04') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
    end
    
    % 生成标签
    TriggerRepeat = repmat(Trigger,1,256);  % 生成标签
    % 脑电信号采集
%     tic
    pause(1);
%     [~, data] = ClientGetDataPacket(con,basicInfo,infoList,startStop,init); % Obtain EEG data, 需要在ClientGetDataPacket设置要不要移除基线
%     toc
%     data = [data;TriggerRepeat];
%     TrialData = [TrialData,data];
    Timer = Timer + 1;
    
    if Timer == 13
        Timer = 0;  % 计时器清0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(RandomTrial(AllTrial))]);  % 显示相关数据
    end
    
end
%% 存储数据
% close all
% TrialData = TrialData(2:end,:);  %去掉矩阵第一行
% ChanLabel = flip({infoList.chanLabel});
% pnet('closeall')   % 将连接关闭
% 
% save(FunctionNowFilename('Offline_EEGdata_', '.mat' ),'TrialData','TrialIndex','ChanLabel');

