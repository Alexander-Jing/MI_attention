%% �������ƺ�ʵ����ļ���
root_path = 'F:\MI_engagement\MI_attention\MI_Training';  % ��Ŀ¼���ڴ洢���ݺͷ���
subject_name_post = 'Jyt_test_0310_post_control'; %'Jyt_test_0101_1_online';% 'Jyt_test_0101_online'; %  % ��������
sub_post_collection_folder = 'Jyt_test_0310_post_control_20240310_212613989_data';

subject_name_pre = 'Jyt_test_0310_pre_control';
sub_pre_collection_folder = 'Jyt_test_0310_pre_control_20240310_204214585_data';

subject_name_offline =  'Jyt_test_0310_offline';  % �����ռ�����ʱ��ı�������
sub_offline_collection_folder = 'Jyt_test_0310_offline_20240310_195952653_data';  % ���Ե����߲ɼ�����

%channels_preprocessing = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15, 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];   
channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,  15, 16,17,18,19,  21,22,23,24,25,26,27,28,29,30,31,32]; 
%channels = [1,2,3,4,5,6,7,8,9,10,11,12,13, 14, 15, 16,17,18,19, 20, 21,22,23,24,25,26,27,28,29,30,31,32];  

mu_channels = struct('C3',24, 'C4',22);  
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  
motorclasses = 3;
channels_num = length(channels);

%% ���ݶ�ȡ
rawdata_pre_folder = fullfile(root_path, sub_pre_collection_folder,['Offline_EEGMI_RawData_', subject_name_pre]);
rawdata_pre_file = dir(fullfile(rawdata_pre_folder, '*.mat'));
rawdata_pre = load(fullfile(rawdata_pre_folder, rawdata_pre_file.name));
rawdata_pre = rawdata_pre.TrialData;

rawdata_post_folder = fullfile(root_path, sub_post_collection_folder,['Offline_EEGMI_RawData_', subject_name_post]);
rawdata_post_file = dir(fullfile(rawdata_post_folder, '*.mat'));
rawdata_post = load(fullfile(rawdata_post_folder, rawdata_post_file.name));
rawdata_post = rawdata_post.TrialData;
%% ���ݴ���
sample_frequency = 256; 

WindowLength = 512;  
SlideWindowLength = 256;  

[Idle_all_pre, MIDrinking_all_pre, MIPouring_all_pre] = process_data(rawdata_pre, sample_frequency, WindowLength, SlideWindowLength, ...
    channels, channels_num);
[Idle_all_post, MIDrinking_all_post, MIPouring_all_post] = process_data(rawdata_post, sample_frequency, WindowLength, SlideWindowLength, ...
    channels, channels_num);

% ��1��ͼ
subplot(2,2,1);
topo_painting = MIDrinking_all_pre-Idle_all_pre;
topoplot([topo_painting;],'Cap30_1.locs','maplimits',[-1.0,1.0], 'electrodes', 'on', 'style', 'map');
title('MIDrinking pre');

% ��2��ͼ
subplot(2,2,2);
topo_painting = MIPouring_all_pre-Idle_all_pre;
topoplot([topo_painting;],'Cap30_1.locs','maplimits',[-1.0,1.0], 'electrodes', 'on', 'style', 'map');
title('MIPouring pre');

% ��3��ͼ
subplot(2,2,3);
topo_painting = MIDrinking_all_post-Idle_all_post;
topoplot([topo_painting;],'Cap30_1.locs','maplimits',[-1.0,1.0], 'electrodes', 'on', 'style', 'map');
title('MIDrinking post');

% ��4��ͼ
subplot(2,2,4);
topo_painting = MIPouring_all_post-Idle_all_post;
topoplot([topo_painting;],'Cap30_1.locs','maplimits',[-1.0,1.0], 'electrodes', 'on', 'style', 'map');
title('MIPouring post');
%% �����ֵ�Ĵ�������
function [Idle_all, MIDrinking_all, MIPouring_all] = process_data(rawdata, sample_frequency, WindowLength, SlideWindowLength, channels, channels_num)
    % ���ݴ���
    Trigger = double(rawdata(end,:)); 

    class_index = 6;
    RawDataIdle = double(rawdata(1:end-1, Trigger == class_index));  
    FilteredDataIdle = DataFilter(RawDataIdle, sample_frequency);  
    [windows_per_session, SampleDataPre] = WindowsDataPre(FilteredDataIdle, WindowLength, SlideWindowLength);
    [DataSampleIdle, ] = DataWindows(SampleDataPre, FilteredDataIdle, channels, class_index, windows_per_session, SlideWindowLength, WindowLength);

    class_index = 1;
    RawDataMI_Drinking = double(rawdata(1:end-1, Trigger == class_index));  
    FilteredDataMI_Drinking = DataFilter(RawDataMI_Drinking, sample_frequency);  
    [windows_per_session, SampleDataPre] = WindowsDataPre(FilteredDataMI_Drinking, WindowLength, SlideWindowLength);
    [DataSampleMI_Drinking, ] = DataWindows(SampleDataPre, FilteredDataMI_Drinking, channels, class_index, windows_per_session, SlideWindowLength, WindowLength);

    class_index = 2;
    RawDataMI_Pouring = double(rawdata(1:end-1, Trigger == class_index));  
    FilteredDataMI_Pouring = DataFilter(RawDataMI_Pouring, sample_frequency);  
    [windows_per_session, SampleDataPre] = WindowsDataPre(FilteredDataMI_Pouring, WindowLength, SlideWindowLength);
    [DataSampleMI_Pouring, ] = DataWindows(SampleDataPre, FilteredDataMI_Pouring, channels, class_index, windows_per_session, SlideWindowLength, WindowLength);

    % �����ֵ
    Idle_all = zeros(channels_num, 1);
    MIDrinking_all = zeros(channels_num, 1);
    MIPouring_all = zeros(channels_num, 1);

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

end

%% 閸忔湹缍戦崙鑺ユ殶闁劌鍨庨敍灞藉瘶閹奉剚鎶ゅ▔�???浣稿灊缁愭鍤遍�??
% 濠娿倖灏濋崙鑺ユ�?
function FilteredData = DataFilter(RawData, sample_frequency) 
    FilterOrder = 4;  % 鐠佸墽鐤嗙敮�???姘姢濞夈垹娅掗惃鍕▉�???
    NotchFilterOrder = 2;  % 鐠佸墽鐤嗛梽閿嬪皾濠娿�?�灏濋崳銊ф畱闂冭埖鏆熼敍鍫ｇ箹闁插奔濞囬悽銊ュ弽閻楄鐭�?弬顖氱敨闂冪粯鎶ゅ▔銏犳珤閿??
    %Wband = [3,50];  % 濠娿倖灏濋崳銊ㄧ箹鏉堝綊娓剁憰浣稿棘閼板啰娴夐崗宕囨畱閺傚洨灏炴潻娑滎攽娣囶喗鏁奸敍�?冪箹闁插苯寮懓鍐у尃閺勭喎绗?婵劗娈戠拋鐑樻瀮娑擃厾娈戝銈嗗皾閸ｃ劏顔曠純?
    Wband = [8,12];
    Wband_notch = [49,51];
    FilterType = 'bandpass';
    FilterTypeNotch = 'stop';  % matlab閻ㄥ垺utter閸戣姤鏆熼柌�?勬桨閿涘矁顔曠純?'stop'娴兼俺鍤滈崝銊啎缂冾喗�??2闂冭埖鎶ゅ▔銏犳�?

    % 娴ｈ法鏁ら梽閿嬪皾濠娿�?�灏濋崳銊ュ箵闂勩�?�浼愭０鎴濇珨婢??
    FilteredData = Rsx_ButterFilter(NotchFilterOrder,Wband_notch,sample_frequency,FilterTypeNotch,RawData,size(RawData,1));
    % 娴ｈ法鏁ょ敮�???姘姢濞夈垹娅掗崢濠氭珟閸ｎ亜锛?
    FilteredData = Rsx_ButterFilter(FilterOrder,Wband,sample_frequency,FilterType,FilteredData,size(FilteredData,1)); 
end

% 鐠侊紕鐣婚崚鎺旂崶閻ㄥ嫬鍤遍�??
function [windows_per_session, DataSamplePre] = WindowsDataPre(RawData, WindowLength, SlideWindowLength)
    data_points_per_session = size(RawData,2);  % 濮ｅ繋绔存稉鐚籩ssion閻ㄥ嫭鏆熼幑�??�??
    % seconds_per_session  = size(EIRawData,2)/sample_frequency;  % 濮ｅ繋绔存稉鐚籩ssion閻ㄥ嫭妞傞梻鎾毐鎼??

    windows_per_session = (data_points_per_session - WindowLength) / SlideWindowLength + 1;  % session濠婃垹鐛ラ崥搴ｆ畱缁愭鏆熼�??

    % shape: (1, number of windows in this session)
    DataSamplePre = cell(1, windows_per_session);
end

% 閸掓帞鐛ラ崙鑺ユ�?
function [DataSample, LabelWindows] = DataWindows(DataSamplePre, FilteredData, channels, class_index, windows_per_session, SlideWindowLength, WindowLength, sample_frequency)
    % channels = [3:32]; 
    % channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; 
    % channels = [3,8,27,28,30,31,32,33]-1;  % 绾喖鐣鹃崜宥夘杺閸欏墎娈戦柅姘朵壕閿涘瞼鏁辨禍搴ゎ唶瑜版洜娈戞穱鈥冲娇CH-1閺勭柖rigger閿涘本澧嶆禒銉﹀閺堝娈戠槐銏犵穿閸戝繐骞?1
    LabelWindows = [];
    % scores = [];  % 閻劋绨�??涙ê鍋峴cores閸掑棙鏆熼惃鍕殶缂??

    % 閻㈢喐鍨氶崚鎺旂崶閻ㄥ嫭鏆熼�??
    for i = 1:windows_per_session
        PointStart = (i-1)*SlideWindowLength;  % 閸︺劍鏆熼幑顔昏厬绾喖鐣剧挧宄邦潗�???
        DataSamplePre{1, i} = FilteredData(channels, PointStart + 1:PointStart + WindowLength );  % 閻㈢喐鍨氶崚鎺旂崶閻ㄥ嫬鍘撶�??
        LabelWindows = [LabelWindows; class_index];  % 閻㈢喐鍨氱憗鍗╝bel閻ㄥ嫭鏆熼幑?
    end
    DataSample = DataSamplePre;
end

