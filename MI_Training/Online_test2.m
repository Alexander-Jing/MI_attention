%% 准备初始的存储数据的文件夹
subject_name = 'FS_test';  % 被试的姓名  

foldername = ['.\\', subject_name]; % 指定文件夹路径和名称

if ~exist(foldername, 'dir')
   mkdir(foldername);
end

%% 生成任务安排调度
Trigger = 0;                                                               % 初始化Trigger，用于后续的数据存储
AllTrial = 0;

session_idx = 1;

MotorClass = 3; % 注意这里是纯设计的运动想象动作的数量，不包括空想idle状态
MajorPoportion = 0.6;
TrialNum = 40;
DiffLevels = [2,1,0];

if session_idx == 1  % 如果是第一个session，那需要生成相关的任务集合
    Level2task(MotorClass, MajorPoportion, TrialNum, DiffLevels, foldername, subject_name);
    path = [foldername, '\\', 'Level2task', '_', subject_name, '\\', 'Online_EEGMI_session_', subject_name, '_', num2str(session_idx), '_', '.mat'];
    ChoiceTrial = load(path,'session');
else
    path = [foldername, '\\', 'Level2task', '_', subject_name, '\\', 'Online_EEGMI_session_', subject_name, '_', num2str(session_idx), '_', '.mat'];
    ChoiceTrial = load(path,'session');
end

ChoiceTrial = ChoiceTrial.session;
% ChoiceTrial = [0,1,2,3];  % 临时使用
%% 开始实验，离线采集
Timer = 0;
TrialData = [];
MaxMITime = 30; % 在线运动想象最大允许时间 
sample_frequency = 256; 
WindowLength = 512;  % 每个窗口的长度
channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道
mu_channel = 14;  % 用于计算ERD/ERS的几个channels，需要确定下位置的
EI_channel = 10;  % 用于计算EI指标的几个channels，需要确定下位置的
weight_mu = 0.6;  % 用于计算ERD/ERS指标和EI指标的加权和
scores = [];  % 用于存储每一个trial里面的分数值
scores_trial = [];  % 用于存储每一个trial的平均分数值
ip = '172.18.22.21';
port = 8888;  % 和后端服务器连接的两个参数
clsFlag = 0; % 用于判断实时分类是否正确的flag

Trials = [];
Trials = [Trials, ChoiceTrial(1,1)];  % 初始化RandomTrial，第一个数值是ChoiceTrial任务集合中的第一个
results = [];

for trial_idx = 1:length(ChoiceTrial)
   for timer = 1:10
       pause(1);
       
       if rem(timer,5)==0
           disp('*********Online Testing***********');
           rawdata = rand(32,512);  % 生成原始的数据，以及去掉了trigger==6的部分
           Trigger = [ChoiceTrial(1,trial_idx) * ones(1,512)]; 
           rawdata = [rawdata; Trigger];  % 生成所有数据
           [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess(rawdata, ChoiceTrial(1,trial_idx), sample_frequency, WindowLength, channels);
           score = weight_mu * sum(mu_power_MI) + (1 - weight_mu) * sum(EI_index);  % 计算得分，这里临时使用求和来表征，后续需要修改
           config_data = [WindowLength;size(channels, 2);ChoiceTrial(1,trial_idx);session_idx;trial_idx;timer/5;score;0;0;0;0 ];
           order = 1.0;
           resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data, foldername);  % 传输数据给线上的模型，看分类情况
           
           disp(['session: ', num2str(session_idx)]);
           disp(['trial: ', num2str(trial_idx)]);
           disp(['window: ', num2str(timer/5)]);
           disp(['moter_class: ', num2str(ChoiceTrial(1,trial_idx))]);
           disp(['predict_class: ', num2str(resultMI)]);
       end
       if timer == 10
           disp('*********Online Updating');
           % 传输数据和更新模型
           config_data = [WindowLength;size(channels, 2);ChoiceTrial(1,trial_idx);session_idx;trial_idx;timer/5;score;0;0;0;0 ];
           order = 2.0;  % 传输数据和训练的命令
           Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % 发送指令，让服务器更新数据，[0,0,0,0]单纯是用于凑下数据，防止应为空集影响传输
           results = [results, resultMI];
           disp(['session: ', num2str(session_idx)]);
           disp(['trial: ', num2str(trial_idx)]);
           disp('training model');
       end    
   end
end

s1 = scatter(1:length(results), results(:));
s1.MarkerFaceColor = '#ff474c';
s1.MarkerEdgeColor = '#ff474c';
hold on
s2 = scatter(1:length(ChoiceTrial), ChoiceTrial(:));
s2.MarkerFaceColor = '#0485d1';
s2.MarkerEdgeColor = '#0485d1';
legend('results', 'ChoiceTrial');  % 添加图例

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
        path = [foldername, '\\', 'Online_EEGMI_session_', subject_name, '_', num2str(SessionIndex), '_', '.mat'];
        save(path,'session');  % 存储相关数据，后面存储用
    end
    
end