%% 数据传输函数设计和服务器端python处理数据测试

rawdata = rand(31,600*256);  % 生成原始的数据，以及去掉了trigger==6的部分
trigger = [zeros(1,150*256), ones(1,150*256), 2*ones(1,150*256), 3*ones(1,150*256)]; 

rawdata = [rawdata; trigger];  % 生成所有数据

%% 设置相关参数
subject_name = 'Jyt';
classes = 4;

%% 数据预处理
% 划窗参数设置
sample_frequency = 256; 
WindowLength = 512;  % 每个窗口的长度
SlideWindowLength = 256;  % 滑窗间隔
channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道
[DataX, DataY, windows_per_session] = Offline_DataPreprocess(rawdata, classes, sample_frequency, WindowLength, SlideWindowLength, channels);
% 预处理之后的数据存储，如果下面传输失败，直接将这两个mat文件送到服务器里
save(FunctionNowFilename(['Offline_EEG_data_', subject_name], '.mat' ),'DataX');
save(FunctionNowFilename(['Offline_EEG_label_', subject_name], '.mat' ),'DataY');

%% 预处理数据传输
% 设置传输的参数
ip = '172.18.22.21';
port = 8888;
config_data = [WindowLength, size(channels, 2), windows_per_session, classes];
Offline_Data2Server_Send(DataX, ip, port, subject_name, config_data);
