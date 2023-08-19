function [random_X, random_Y] = Offline_DataPreprocess(rawdata, seconds_per_trial, classes)    
    %% �ɼ�����
    sample_frequency = 256; 
    data_points_per_trial = sample_frequency * seconds_per_trial;
    
    WindowLength = 512;  % ÿ�����ڵĳ���
    SlideWindowLength = 256;  % �������
    
    Trigger = rawdata(end,:); %rawdata���һ��
    RawData = rawdata(1:32, Trigger~=6);
    Labels = rawdata(33, Trigger~=6);  % �ռ�rawdata��label
    
    data_points_per_session = size(EIRawData,2);  % ÿһ��session��������
    % seconds_per_session  = size(EIRawData,2)/sample_frequency;  % ÿһ��session��ʱ�䳤��
    
    windows_per_session = (data_points_per_session - WindowLength) / SlideWindowLength + 1;  % session������Ĵ�����
    
    % shape: (1, number of windows in this session)
    DataSample = cell(1, windows_per_session);
    
    %% �˲�Ԥ����
    
    
    %% ��������󣬽�ÿ������������ȡ��
    
    
    
    %% �˲�����
    function FilteredData = DataFilter(RawData, sample_frequency) 
        FilterOrder = 4;  % ���ô�ͨ�˲����Ľ���
        NotchFilterOrder = 2;  % �����ݲ��˲����Ľ���������ʹ�ð�����˹�����˲�����
        Wband = [3,50];  % �˲��������Ҫ�ο���ص����׽����޸ģ�����ο�����ʦ��������е��˲�������
        Wband_notch = [49,51];
        FilterType = 'bandpass';
        FilterTypeNotch = 'stop';  % matlab��butter�������棬����'stop'���Զ����ó�2���˲���

        % ʹ���ݲ��˲���ȥ����Ƶ����
        FilteredData = Rsx_ButterFilter(NotchFilterOrder,Wband_notch,sample_frequency,FilterTypeNotch,RawData,size(RawData,1));
        % ʹ�ô�ͨ�˲���ȥ������
        FilteredData = Rsx_ButterFilter(FilterOrder,Wband,sample_frequency,FilterType,FilteredData,size(FilteredData,1)); 
    end
    
    %% ��������
    function DataSample = DataWindows(channels, windows_per_session, SlideWindowLength, WindowLength)
        % channels = [3:32]; 
        % channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; 
        % channels = [3,8,27,28,30,31,32,33]-1;  % ȷ��ǰ��Ҷ��ͨ�������ڼ�¼���ź�CH-1��Trigger���������е�������ȥ1
        LabelWindows = [];

        % ���ɻ���������
        for i = 1:windows_per_session
            PointStart = (i-1)*SlideWindowLength;  % ��������ȷ����ʼ��
            DataSample{1, i} = FilteredData(channels,PointStart + 1:PointStart + WindowLength );

        end
    end
end