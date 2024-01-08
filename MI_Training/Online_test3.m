%% 初始化，关闭�?有连�?
pnet('closeall');
clc;
clear;
close all;
%% 启动Unity程序，并初始�?
% 程序说明：发送命令共5字节
%           Byte1：画�?/动作切换
%           Byte2：控制画面是否运�?
%           Byte3：画面文字显示（离线训练实验无文字提示）
%           Byte4：动作类�?
%           Byte5：预�?
%system('F:\CASIA\mwl_data_collection\climbstair\ClimbStair3.exe&');       % Unity动画exe文件地址
%system('E:\MI_engagement\unity_test\unity_test\build_test\unity_test.exe&');
%system('E:\UpperLimb_Animation\unity_test.exe&');
%system('E:\MI_AO_Animation\UpperLimb_Animation\unity_test.exe&');
system('E:\MI_AO_Animation\UpperLimb_Animation_modified\unity_test.exe&');
%system('F:\MI_UpperLimb_AO\UpperLimb_AO\UpperLimb_Animation\unity_test.exe&');
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

%% 准备初始的存储数据的文件�?
subject_name = 'Jyt_test_online';  % 被试的姓�?  

foldername = ['.\\', subject_name]; % 指定文件夹路径和名称

if ~exist(foldername, 'dir')
   mkdir(foldername);
end

%% 生成任务安排调度
Trigger = 0;                                                               % 初始化Trigger，用于后续的数据存储
AllTrial = 0;

session_idx = 1;

MotorClass = 2; % 注意这里是纯设计的运动想象动作的数量，不包括空想idle状�??
MajorPoportion = 0.6;
TrialNum = 6;
DiffLevels = [1,2];

% if session_idx == 1  % 如果是第�?个session，那�?要生成相关的任务集合
%     Level2task(MotorClass, MajorPoportion, TrialNum, DiffLevels, foldername, subject_name);
%     path = [foldername, '\\', 'Level2task', '_', subject_name, '\\', 'Online_EEGMI_session_', subject_name, '_', num2str(session_idx), '_', '.mat'];
%     ChoiceTrial = load(path,'session');
% else
%     path = [foldername, '\\', 'Level2task', '_', subject_name, '\\', 'Online_EEGMI_session_', subject_name, '_', num2str(session_idx), '_', '.mat'];
%     ChoiceTrial = load(path,'session');
% end

%ChoiceTrial = ChoiceTrial.session;
 ChoiceTrial = [1,2,0,1,2,0,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2];  % 临时使用
%% �?始实验，离线采集
Timer = 0;
TrialData = [];
MaxMITime = 30; % 在线运动想象�?大允许时�? 
sample_frequency = 256; 
WindowLength = 512;  % 每个窗口的长�?
channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��,
mu_channels = struct('C3',24, 'C4',22);  % ���ڼ���ERD/ERS�ļ���channels����C3��C4����ͨ��,��Ҫ�趨λ��
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�
weight_mu = 0.6;  % 用于计算ERD/ERS指标和EI指标的加权和
scores = [];  % 用于存储每一个trial里面的分数�??
scores_trial = [];  % 用于存储每一个trial的平均分数�??
ip = '172.18.22.21';
port = 8888;  % 和后端服务器连接的两个参�?
clsFlag = 0; % 用于判断实时分类是否正确的flag

Trials = [];
Trials = [Trials, ChoiceTrial(1,1)];  % 初始化RandomTrial，第�?个数值是ChoiceTrial任务集合中的第一�?
results = [];
resultMI = Trigger;

for trial_idx = 1:length(ChoiceTrial)
    score_thre = trial_idx * 25;
    for timer = 1:30
       pause(1);
       if rem(timer,1)==0 && timer <= 10
           disp('*********Online Testing***********');
           Trigger = ChoiceTrial(trial_idx);  % 播放动作的AO动画（Idle, MI1, MI2�?
           mat2unity = ['0', num2str(Trigger + 3)];
           sendbuf(1,1) = hex2dec(mat2unity);
           sendbuf(1,2) = hex2dec('00');
           sendbuf(1,3) = hex2dec('00');
           sendbuf(1,4) = hex2dec('00');
           % threshold 数据传输设置以及显示
           sendbuf(1,6) = uint8((score_thre));
           fwrite(UnityControl,sendbuf);  

           rawdata = rand(33,512);  % 生成原始的数据，以及去掉了trigger==6的部�?
           Trigger = [ChoiceTrial(1,trial_idx) * ones(1,512)]; 
           rawdata = [rawdata; Trigger];  % 生成�?有数�?
           [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess(rawdata, ChoiceTrial(1,trial_idx), sample_frequency, WindowLength, channels);
           score = weight_mu * sum(mu_power_MI) + (1 - weight_mu) * sum(EI_index);  % 计算得分，这里临时使用求和来表征，后续需要修�?
           
           
           
           config_data = [WindowLength;size(channels, 2);ChoiceTrial(1,trial_idx);session_idx;trial_idx;timer;score;0;0;0;0 ];
           order = 1.0;
           
           resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data, foldername);  % 传输数据给线上的模型，看分类情况
           % score 数据传输设置
           sendbuf(1,5) = uint8(score/100.0);
           fwrite(UnityControl,sendbuf);
           
           disp(['session: ', num2str(session_idx)]);
           disp(['trial: ', num2str(trial_idx)]);
           disp(['window: ', num2str(timer/5)]);
           disp(['moter_class: ', num2str(ChoiceTrial(1,trial_idx))]);
           %disp(['predict_class: ', num2str(resultMI(1,1))]);
           %disp(['predict_probilities: ', num2str(resultMI(2,1))]);
           disp(['score: ', num2str(score)]);
       end
       if timer == 10
           disp('*********Online Updating');
           % 传输数据和更新模�?
           config_data = [WindowLength;size(channels, 2);ChoiceTrial(1,trial_idx);session_idx;trial_idx;timer/5;score;0;0;0;0 ];
           order = 2.0;  % 传输数据和训练的命令
           Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % 发�?�指令，让服务器更新数据，[0,0,0,0]单纯是用于凑下数据，防止应为空集影响传输
           results = [results, resultMI];
           
           sendbuf(1,2) = hex2dec('01');
           sendbuf(1,3) = hex2dec('02');
           fwrite(UnityControl,sendbuf);

           disp(['session: ', num2str(session_idx)]);
           disp(['trial: ', num2str(trial_idx)]);
           disp('training model');
       end
       if timer == 13
           sendbuf(1,1) = hex2dec('02') ;
           sendbuf(1,2) = hex2dec('00') ;
           sendbuf(1,3) = hex2dec('00') ;
           sendbuf(1,4) = hex2dec('00') ;
           fwrite(UnityControl,sendbuf); 
       end
           
   end
end

% s1 = scatter(1:length(results), results(:));
% s1.MarkerFaceColor = '#ff474c';
% s1.MarkerEdgeColor = '#ff474c';
% hold on
% s2 = scatter(1:length(ChoiceTrial), ChoiceTrial(:));
% s2.MarkerFaceColor = '#0485d1';
% s2.MarkerEdgeColor = '#0485d1';
% legend('results', 'ChoiceTrial');  % 添加图例

%% 任务初始生成的函�?
function Level2task(MotorClasses, MajorPoportion, TrialNum, DiffLevels, foldername, subject_name)  % MajorPoportion 每一个session中的主要动作的比例；TrailNum 每一个session中的trial数量, DiffLevels从低到高生成难度的矩阵，矩阵里的数�?�越高表示难度越�? 
    
    foldername = [foldername, '\\', 'Level2task', '_', subject_name]; % 指定文件夹路径和名称
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end
    
    for SessionIndex = 1:MotorClasses  % 这里的SessionIndex也是主要难度对应的位�?
        session = [];
        MotorMain = DiffLevels(1, SessionIndex);  % 主要成分的运�?
        NumMain = round(TrialNum * MajorPoportion);  
        session = [session, repmat(MotorMain, 1, NumMain)];
        
        indices = find(DiffLevels==MotorMain);  % 找到MotorMain对应的index
        DiffLevels_ = DiffLevels;
        DiffLevels_(indices) = [];  % 去掉MotorMain的剩下的难度矩阵
        
        for i_=1:(MotorClasses - 1)
            MotorMinor = DiffLevels_(1, i_);  % 剩下的几个动�?
            MinorProportion =  (1-MajorPoportion)/(MotorClasses - 1);  % 剩下动作的比�?
            NumMinor = round(TrialNum * MinorProportion);
            session = [session, repmat(MotorMinor, 1, NumMinor)];  % 添加剩下的动�?
        end    
        session = [session, repmat(0, 1, NumMinor)];  % 添加和剩下动作一致比例的空想动作
        path = [foldername, '\\', 'Online_EEGMI_session_', subject_name, '_', num2str(SessionIndex), '_', '.mat'];
        save(path,'session');  % 存储相关数据，后面存储用
    end
    
end