% 初始化数据数组  
FilteredData = rand(32, 256*1000);
% channels = [3:32]; 
channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; 
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