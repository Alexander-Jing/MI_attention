function [random_X, random_Y] = Offline_DataPreprocess(rawdata, seconds_per_trial, classes)    
    %% 采集参数
    sample_frequency = 256; 
    data_points_per_trial = sample_frequency * seconds_per_trial;
    
    WindowLength = 512;  % 每个窗口的长度
    SlideWindowLength = 256;  % 滑窗间隔
    
    Trigger = rawdata(end,:); %rawdata最后一行
    RawData = rawdata(1:32, Trigger~=6);
    Labels = rawdata(33, Trigger~=6);  % 收集rawdata和label
    
    data_points_per_session = size(EIRawData,2);  % 每一个session的数据量
    % seconds_per_session  = size(EIRawData,2)/sample_frequency;  % 每一个session的时间长度
    
    windows_per_session = (data_points_per_session - WindowLength) / SlideWindowLength + 1;  % session滑窗后的窗数量
    
    % shape: (1, number of windows in this session)
    DataSample = cell(1, windows_per_session);
    
    %% 滤波预处理
    
    
    %% 滑窗处理后，将每个窗口数据提取出
    
    
    
    %% 滤波函数
    function FilteredData = DataFilter(RawData, sample_frequency) 
        FilterOrder = 4;  % 设置带通滤波器的阶数
        NotchFilterOrder = 2;  % 设置陷波滤波器的阶数（这里使用巴特沃斯带阻滤波器）
        Wband = [3,50];  % 滤波器这边需要参考相关的文献进行修改，这里参考佳星师姐的论文中的滤波器设置
        Wband_notch = [49,51];
        FilterType = 'bandpass';
        FilterTypeNotch = 'stop';  % matlab的butter函数里面，设置'stop'会自动设置成2阶滤波器

        % 使用陷波滤波器去除工频噪声
        FilteredData = Rsx_ButterFilter(NotchFilterOrder,Wband_notch,sample_frequency,FilterTypeNotch,RawData,size(RawData,1));
        % 使用带通滤波器去除噪声
        FilteredData = Rsx_ButterFilter(FilterOrder,Wband,sample_frequency,FilterType,FilteredData,size(FilteredData,1)); 
    end
    
    %% 划窗函数
    function DataSample = DataWindows(channels, windows_per_session, SlideWindowLength, WindowLength)
        % channels = [3:32]; 
        % channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; 
        % channels = [3,8,27,28,30,31,32,33]-1;  % 确定前额叶的通道，由于记录的信号CH-1是Trigger，所以所有的索引减去1
        LabelWindows = [];

        % 生成划窗的数据
        for i = 1:windows_per_session
            PointStart = (i-1)*SlideWindowLength;  % 在数据中确定起始点
            DataSample{1, i} = FilteredData(channels,PointStart + 1:PointStart + WindowLength );

        end
    end
end