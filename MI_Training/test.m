%% 数据预处理设计
% 初始化数据数组  
FilteredData = rand(32, 256*1000);
% channels = [3:32]; 
channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; 
size(channels)
% channels = [3,8,27,28,30,31,32,33]-1;  % 确定前额叶的通道，由于记录的信号CH-1是Trigger，所以所有的索引减去1
DataX = [];
DataY = [];
LabelWindows = [];
sample_frequency = 256; 
data_points_per_trial = sample_frequency * 10;
class_index = 1;
WindowLength = 512;  % 每个窗口的长度
SlideWindowLength = 256;  % 滑窗间隔
    

data_points_per_session = size(FilteredData,2);  % 每一个session的数据量
% seconds_per_session  = size(EIRawData,2)/sample_frequency;  % 每一个session的时间长度

windows_per_session = (data_points_per_session - WindowLength) / SlideWindowLength + 1  % session滑窗后的窗数量

% shape: (1, number of windows in this session)
DataSamplePre = cell(1, windows_per_session);

% 生成划窗的数据
for i = 1:windows_per_session
    PointStart = (i-1)*SlideWindowLength;  % 在数据中确定起始点
    DataSamplePre{1, i} = FilteredData(channels, PointStart + 1:PointStart + WindowLength );  % 生成划窗的元祖
    LabelWindows = [LabelWindows; class_index];  % 生成装label的数组
end
DataSamlpe = DataSamplePre;
LabelY = LabelWindows;

DataX = [DataX; DataSamplePre];
DataX = [DataX; DataSamlpe];

DataY = [DataY; LabelWindows];
DataY = [DataY; LabelY];

save('DataX.mat','DataX');

 data_x = load('DataX.mat','DataX');
% % disp(data_x.DataX{1,1});
%% 数据传输测试
% 将cell形式的数据重新转换成矩阵的形式
data_x = data_x.DataX;
config = whos('data_x');
data2Server = [];
h = waitbar(0, '数据转换');
for class_type = 1:config.size(1,1)
   for windows_num = 1:config.size(1,2)
       size_ = size(data2Server);
       waitbar((size_(1)/30)/(config.size(1,1)*config.size(1,2)), h); 
       data2Server = [data2Server;data_x{class_type,windows_num}];
   end
end
save('data2Server.mat','data2Server');

data2Server = load('data2Server.mat','data2Server');
data2Server = struct2array(data2Server);
config_data = [512;30;999;2];  % 登记上传的数据的相关参数
time_out = 60; % 投送数据包的等待时间
tcpipClient = tcpip('172.18.22.21', 8888,'NetworkRole','Client');
set(tcpipClient,'OutputBufferSize',4*999*30*256*8*10);%2048*4096 67108880+64
set(tcpipClient,'Timeout',time_out);
tcpipClient.InputBufferSize = 8388608;%8M
tcpipClient.ByteOrder = 'bigEndian';
fopen(tcpipClient);
disp("连接成功")
disp("数据发送")

send_order = 3.0;  % 发送命令控制，用于控制服务器
send_data = [send_order; config_data(:); data2Server(:)];
config_send = whos('send_data');   % whos('send_data')将返回该变量的名称、大小、字节数、类型等信息
fwrite(tcpipClient,[config_send.bytes/2; send_data],'float32');  % 这里matlab的double是8个字节，然后这里使用的4字节的float32传输，所以config_send.bytes要除以2，表示使用4字节的float32形式传输用了多少个字节

fwrite(tcpipClient,dataBytes,'float32');

fclose(tcpipClient);