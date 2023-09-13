function [DataX, DataY, windows_per_session] = Offline_DataPreprocess(rawdata, classes, sample_frequency, WindowLength, SlideWindowLength, channels, subject_name, foldername)    
    %% �ɼ�����
    %sample_frequency = 256; 
    
    %WindowLength = 512;  % ÿ�����ڵĳ���
    %SlideWindowLength = 256;  % �������
    
    Trigger = double(rawdata(end,:)); %rawdata���һ��
    RawData = double(rawdata(1:end-1, Trigger~=6));
    %channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��
    
    DataX = [];
    DataY = [];  % ��ʼ�������X��Y������
    
    for class_index = 0:(classes-1)
        RawDataMI = RawData(:, Trigger==class_index);  % ��ȡ��һ����˶���������
        FilteredDataMI = DataFilter(RawDataMI, sample_frequency);  % �˲�ȥ��
        [windows_per_session, SampleDataPre] = WindowsDataPre(FilteredDataMI, WindowLength, SlideWindowLength);
        [DataSample, LabelWindows] = DataWindows(SampleDataPre, FilteredDataMI, channels, class_index, windows_per_session, SlideWindowLength, WindowLength);
        DataX = [DataX; DataSample];
        DataY = [DataY, LabelWindows];
    end
    
    % ��;������Ҫ���͵����� 
    foldername = [foldername, '\\Offline_EEGMI_', subject_name]; % ָ���ļ���·��������
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end
    % Ԥ����֮������ݴ洢��������洫��ʧ�ܣ�ֱ�ӽ�������mat�ļ��͵���������
    save([foldername, '\\', FunctionNowFilename(['Offline_EEG_data_', subject_name], '.mat' )],'DataX');
    save([foldername, '\\', FunctionNowFilename(['Offline_EEG_label_', subject_name], '.mat' )],'DataY');

    
    
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
    
    %% ���㻮���ĺ���
    function [windows_per_session, DataSamplePre] = WindowsDataPre(RawData, WindowLength, SlideWindowLength)
        data_points_per_session = size(RawData,2);  % ÿһ��session��������
        % seconds_per_session  = size(EIRawData,2)/sample_frequency;  % ÿһ��session��ʱ�䳤��

        windows_per_session = (data_points_per_session - WindowLength) / SlideWindowLength + 1;  % session������Ĵ�����

        % shape: (1, number of windows in this session)
        DataSamplePre = cell(1, windows_per_session);
    end

    %% ��������
    function [DataSample, LabelWindows] = DataWindows(DataSamplePre, FilteredData, channels, class_index, windows_per_session, SlideWindowLength, WindowLength)
        % channels = [3:32]; 
        % channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; 
        % channels = [3,8,27,28,30,31,32,33]-1;  % ȷ��ǰ��Ҷ��ͨ�������ڼ�¼���ź�CH-1��Trigger���������е�������ȥ1
        LabelWindows = [];

        % ���ɻ���������
        for i = 1:windows_per_session
            PointStart = (i-1)*SlideWindowLength;  % ��������ȷ����ʼ��
            DataSamplePre{1, i} = FilteredData(channels, PointStart + 1:PointStart + WindowLength );  % ���ɻ�����Ԫ��
            LabelWindows = [LabelWindows; class_index];  % ����װlabel������
        end
        DataSample = DataSamplePre;
    end
end