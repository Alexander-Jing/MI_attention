%% 被试名称和实验的文件�?
subject_name_online =   'Jyt_test_0101_online';%'Jyt_test_0108_online'; %%'Jyt_test_0101_1_online';  %  % 被试姓名
sub_online_collection_folder = 'Jyt_test_0101_online_20240101_175129548_data';  %'Jyt_test_0101_1_online_20240101_200123314_data'; %'';%  %'Jyt_test_0108_online_20240110_000906267_data'; %   %''; %  % 
sub_online_rawdata_file = 'Online_EEGMI_RawData_1_Jyt_test_0101_online20240101_181405221';  %;'Online_EEGMI_RawData_1_Jyt_test_0101_1_online20240101_202349586.mat';  

subject_name_offline =  'Jyt_test_0101_1_offline';  % 离线收集数据时�?�的被试名称
sub_offline_collection_folder = 'Jyt_test_0101_1_offline_20240101_193332077_data';  % 被试的离线采集数�?

%channels_preprocessing = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15, 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的�?�道,
channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,  15, 16,17,18,19,  21,22,23,24,25,26,27,28,29,30,31,32];  % 数据去掉M1和M2
%channels = [1,2,3,4,5,6,7,8,9,10,11,12,13, 14, 15, 16,17,18,19, 20, 21,22,23,24,25,26,27,28,29,30,31,32];  % 数据去掉M1和M2

mu_channels = struct('C3',24, 'C4',22);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,�?要设定位�?
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % 用于计算EI指标的几个channels，需要确定下位置�?
motorclasses = 3;
channels_num = length(channels);

%% 读取数据
subject_rawdata_folder = ['.\', sub_online_collection_folder, '\' 'Online_EEGMI_RawData_', subject_name_online];
rawdata = load([subject_rawdata_folder, '\', sub_online_rawdata_file]);
rawdata_comparison = load('F:\CASIA\MI_engagement\MI_attention\MI_Training\Jyt_test_0101_1_comparison_1_20240101_221830944_data\Offline_EEGMI_RawData_Jyt_test_0101_1_comparison_1\Offline_EEGMI_RawData_Jyt_test_0101_1_comparison_120240101_222612681.mat', 'TrialData');
rawdata_offline = load('F:\CASIA\MI_engagement\MI_attention\MI_Training\Jyt_test_0101_offline_20240101_170352928_data\Offline_EEGMI_RawData_Jyt_test_0101_offline\Offline_EEGMI_RawData_Jyt_test_0101_offline20240101_171926945.mat', 'TrialData');
%load('F:\CASIA\MI_engagement\MI_attention\MI_Training\Jyt_test_0101_1_offline_20240101_193332077_data\Offline_EEGMI_RawData_Jyt_test_0101_1_offline\Offline_EEGMI_RawData_Jyt_test_0101_1_offline20240101_194900541.mat', 'TrialData');

rawdata = rawdata.TrialData;
rawdata_comparison = rawdata_comparison.TrialData;
rawdata_offline = rawdata_offline.TrialData;

%raw_data = rawdata_comparison;
%% 采集参数，构建窗�?
sample_frequency = 256; 

WindowLength = 512;  % 每个窗口的长�?
SlideWindowLength = 256;  % 滑窗间隔

Trigger = double(rawdata(end,:)); %rawdata�?后一�
% 静息态数�?
class_index = 6;
RawDataIdle = double(rawdata(1:end-1, Trigger == class_index));  % 提取这一类的静息态数�?
FilteredDataIdle = DataFilter(RawDataIdle, sample_frequency);  % 滤波去噪
[windows_per_session, SampleDataPre] = WindowsDataPre(FilteredDataIdle, WindowLength, SlideWindowLength);
[DataSampleIdle, ] = DataWindows(SampleDataPre, FilteredDataIdle, channels, class_index, windows_per_session, SlideWindowLength, WindowLength);

%运动想象数据1
class_index = 1;
RawDataMI_Drinking = double(rawdata(1:end-1, Trigger == class_index));  % 提取这一类的运动想象数据
FilteredDataMI_Drinking = DataFilter(RawDataMI_Drinking, sample_frequency);  % 滤波去噪
[windows_per_session, SampleDataPre] = WindowsDataPre(FilteredDataMI_Drinking, WindowLength, SlideWindowLength);
[DataSampleMI_Drinking, ] = DataWindows(SampleDataPre, FilteredDataMI_Drinking, channels, class_index, windows_per_session, SlideWindowLength, WindowLength);

%运动想象数据2
class_index = 2;
RawDataMI_Pouring = double(rawdata(1:end-1, Trigger == class_index));  % 提取这一类的运动想象数据
FilteredDataMI_Pouring = DataFilter(RawDataMI_Pouring, sample_frequency);  % 滤波去噪
[windows_per_session, SampleDataPre] = WindowsDataPre(FilteredDataMI_Pouring, WindowLength, SlideWindowLength);
[DataSampleMI_Pouring, ] = DataWindows(SampleDataPre, FilteredDataMI_Pouring, channels, class_index, windows_per_session, SlideWindowLength, WindowLength);

%% 计算PSD图，并且绘制头部脑电地形�?
% 每一个人的PSD均�?�存储，测试代码这里只有我一�?
Idle_all = zeros(channels_num, 1);
MIDrinking_all = zeros(channels_num, 1);
MIPouring_all = zeros(channels_num, 1);

% 计算Idle的用于作为基�?
all_eegdata_idle = zeros(channels_num, size(DataSampleIdle, 2));
for cell_idx = 1 : size(DataSampleIdle, 2)
    eegdata_idle = zeros(channels_num, 1);
    data_filtered = DataSampleIdle{cell_idx}(:, :);
    for channel_idx = 1 : channels_num
        [pxx, f] = pwelch(data_filtered(channel_idx, :), hanning(128), 64, 128, 256);
        eegdata_idle(channel_idx)=10 * log10(mean(pxx));
    end
    all_eegdata_idle(:, cell_idx) = eegdata_idle;
end
Idle_all(:, 1) = mean(all_eegdata_idle, 2);

% 计算MI_Drinking用于绘制
all_eegdata_MI_Drinking = zeros(channels_num, size(DataSampleMI_Drinking, 2));
for cell_idx = 1 : size(DataSampleMI_Drinking, 2)
    eegdata_MI_Drinking = zeros(channels_num, 1);
    data_filtered = DataSampleMI_Drinking{cell_idx}(:, :);
    for channel_idx = 1 : channels_num
        [pxx, f] = pwelch(data_filtered(channel_idx, :), hanning(128), 64, 128, 256);
        eegdata_MI_Drinking(channel_idx)=10 * log10(mean(pxx));
    end
    all_eegdata_MI_Drinking(:, cell_idx) = eegdata_MI_Drinking;
end
MIDrinking_all(:, 1) = mean(all_eegdata_MI_Drinking, 2);

% 计算MI_Pouring用于绘制
all_eegdata_MI_Pouring = zeros(channels_num, size(DataSampleMI_Pouring, 2));
for cell_idx = 1 : size(DataSampleMI_Pouring, 2)
    eegdata_MI_Pouring = zeros(channels_num, 1);
    data_filtered = DataSampleMI_Pouring{cell_idx}(:, :);
    for channel_idx = 1 : channels_num
        [pxx, f] = pwelch(data_filtered(channel_idx, :), hanning(128), 64, 128, 256);
        eegdata_MI_Pouring(channel_idx)=10 * log10(mean(pxx));
    end
    all_eegdata_MI_Pouring(:, cell_idx) = eegdata_MI_Pouring;
end
MIPouring_all(:, 1) = mean(all_eegdata_MI_Pouring, 2);

% 绘制头部脑电地形�?
topo_painting = MIDrinking_all-Idle_all;
topoplot([topo_painting; 0;0;0;0],'Cap30.locs','maplimits',[-1.0,1.0], 'electrodes', 'on', 'style', 'both');


%% 其余函数部分，包括滤波�?�划窗函�?
% 滤波函数
function FilteredData = DataFilter(RawData, sample_frequency) 
    FilterOrder = 4;  % 设置带�?�滤波器的阶�?
    NotchFilterOrder = 2;  % 设置陷波滤波器的阶数（这里使用巴特沃斯带阻滤波器�?
    %Wband = [3,50];  % 滤波器这边需要参考相关的文献进行修改，这里参考佳星师姐的论文中的滤波器设�?
    Wband = [8,12];
    Wband_notch = [49,51];
    FilterType = 'bandpass';
    FilterTypeNotch = 'stop';  % matlab的butter函数里面，设�?'stop'会自动设置成2阶滤波器

    % 使用陷波滤波器去除工频噪�?
    FilteredData = Rsx_ButterFilter(NotchFilterOrder,Wband_notch,sample_frequency,FilterTypeNotch,RawData,size(RawData,1));
    % 使用带�?�滤波器去除噪声
    FilteredData = Rsx_ButterFilter(FilterOrder,Wband,sample_frequency,FilterType,FilteredData,size(FilteredData,1)); 
end

% 计算划窗的函�?
function [windows_per_session, DataSamplePre] = WindowsDataPre(RawData, WindowLength, SlideWindowLength)
    data_points_per_session = size(RawData,2);  % 每一个session的数据量
    % seconds_per_session  = size(EIRawData,2)/sample_frequency;  % 每一个session的时间长�?

    windows_per_session = (data_points_per_session - WindowLength) / SlideWindowLength + 1;  % session滑窗后的窗数�?

    % shape: (1, number of windows in this session)
    DataSamplePre = cell(1, windows_per_session);
end

% 划窗函数
function [DataSample, LabelWindows] = DataWindows(DataSamplePre, FilteredData, channels, class_index, windows_per_session, SlideWindowLength, WindowLength, sample_frequency)
    % channels = [3:32]; 
    % channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; 
    % channels = [3,8,27,28,30,31,32,33]-1;  % 确定前额叶的通道，由于记录的信号CH-1是Trigger，所以所有的索引减去1
    LabelWindows = [];
    % scores = [];  % 用于存储scores分数的数�?

    % 生成划窗的数�?
    for i = 1:windows_per_session
        PointStart = (i-1)*SlideWindowLength;  % 在数据中确定起始�?
        DataSamplePre{1, i} = FilteredData(channels, PointStart + 1:PointStart + WindowLength );  % 生成划窗的元�?
        LabelWindows = [LabelWindows; class_index];  % 生成装label的数�?
    end
    DataSample = DataSamplePre;
end