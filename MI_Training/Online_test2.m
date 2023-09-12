%% 生成任务安排调度
Trigger = 0;                                                               % 初始化Trigger，用于后续的数据存储
AllTrial = 0;

session_idx = 1;

MotorClass = 3; % 注意这里是纯设计的运动想象动作的数量，不包括空想idle状态
MajorPoportion = 0.6;
TrialNum = 40;
DiffLevels = [2,1,3];

if session_idx == 1  % 如果是第一个session，那需要生成相关的任务集合
    Level2task(MotorClass, MajorPoportion, TrialNum, DiffLevels);
    ChoiceTrial = load(['Online_EEGMI_session_', num2str(session_idx), '_', '.mat'],'session');
else
    ChoiceTrial = load(['Online_EEGMI_session_', num2str(session_idx), '_', '.mat'],'session');
end

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
subject_name = 'Jyt';  % 被试的姓名  

Trials = [];
Trials = [Trials, ChoiceTrial(1,1)];  % 初始化RandomTrial，第一个数值是ChoiceTrial任务集合中的第一个

for trial_idx = 1:length(ChoiceTrial)
   for timer = 1:10
       pause(1);
       if rem(timer,5)==0
           rawdata = rand(31,512);  % 生成原始的数据，以及去掉了trigger==6的部分
           trigger = [ChoiceTrial(1,trial_idx) * ones(1,512)]; 
           rawdata = [rawdata; trigger];  % 生成所有数据
           [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess(rawdata, ChoiceTrial(1,trial_idx), sample_frequency, WindowLength, channels);
           score = weight_mu * mu_power_MI + (1 - weight_mu) * EI_index;  % 计算得分
           config_data = [WindowLength;size(channels, 2);ChoiceTrial(1,trial_idx);session_idx;trial_idx;timer/2;score;0;0;0;0 ];
           order = 1.0;
           resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data);  % 传输数据给线上的模型，看分类情况
           disp(['session: ', session_idx]);
           disp(['trial: ', trial_idx]);
           disp(['window: ', timer/2]);
           disp(['moter_class: ', ChoiceTrial(1,trial_idx)]);
           disp(['predict_class: ', resultMI]);
       end
       
   end
end
