%% 鐞氼偉鐦崥宥囆為崪灞界杽妤犲瞼娈戦弬鍥︽婢??
subject_name_online =  'Jyt_test_0125_online_test'; % 'Jyt_test_0101_online';%'Jyt_test_0108_online'; %%  %  % 鐞氼偉鐦慨鎾虫倳
sub_online_collection_folder = 'Jyt_test_0125_online_test_20240125_220854676_data'; %'Jyt_test_0101_online_20240101_175129548_data';  % %'';%  %'Jyt_test_0108_online_20240110_000906267_data'; %   %''; %  % 
sub_online_rawdata_file = 'Online_EEGMI_RawData_1_Jyt_test_0125_online_test20240125_222644225.mat'; %'Online_EEGMI_RawData_1_Jyt_test_0101_online20240101_181405221';  %;;  

subject_name_offline =  'Jyt_test_0125_offline_test';  % 缁傝崵鍤庨弨鍫曟肠閺佺増宓侀弮璺??娆戞畱鐞氼偉鐦崥宥囆?
sub_offline_collection_folder = 'Jyt_test_0125_offline_test_20240125_203932146_data';  % 鐞氼偉鐦惃鍕瀲缁惧潡鍣伴梿鍡樻殶閹??

%channels_preprocessing = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15, 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 闁瀚ㄩ惃鍕??姘朵壕,
channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,  15, 16,17,18,19,  21,22,23,24,25,26,27,28,29,30,31,32];  % 閺佺増宓侀崢缁樺竴M1閸滃2
%channels = [1,2,3,4,5,6,7,8,9,10,11,12,13, 14, 15, 16,17,18,19, 20, 21,22,23,24,25,26,27,28,29,30,31,32];  % 閺佺増宓侀崢缁樺竴M1閸滃2

mu_channels = struct('C3',24, 'C4',22);  % 閻劋绨拋锛勭暬ERD/ERS閻ㄥ嫬鍤戞稉鐚歨annels閿涘本妲窩3閸滃瓔4娑撱倓閲滈柅姘朵壕,闂??鐟曚浇顔曠?规矮缍呯純?
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % 閻劋绨拋锛勭暬EI閹稿洦鐖ｉ惃鍕殤娑撶寶hannels閿涘矂娓剁憰浣衡?樼?规矮绗呮担宥囩枂閻??
motorclasses = 3;
channels_num = length(channels);

%% 鐠囪褰囬弫鐗堝祦
subject_rawdata_folder = ['.\', sub_online_collection_folder, '\' 'Online_EEGMI_RawData_', subject_name_online];
rawdata = load([subject_rawdata_folder, '\', sub_online_rawdata_file]);
rawdata_comparison = load('F:\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_comparison_test_20240125_215803328_data\Offline_EEGMI_RawData_Jyt_test_0125_comparison_test\Offline_EEGMI_RawData_Jyt_test_0125_comparison_test20240125_220607487.mat', 'TrialData');
rawdata_offline = load('F:\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_offline_test_20240125_203932146_data\Offline_EEGMI_RawData_Jyt_test_0125_offline_test\Offline_EEGMI_RawData_Jyt_test_0125_offline_test20240125_205630245.mat', 'TrialData');
%load('F:\CASIA\MI_engagement\MI_attention\MI_Training\Jyt_test_0101_1_offline_20240101_193332077_data\Offline_EEGMI_RawData_Jyt_test_0101_1_offline\Offline_EEGMI_RawData_Jyt_test_0101_1_offline20240101_194900541.mat', 'TrialData');

rawdata = rawdata.TrialData;
rawdata_comparison = rawdata_comparison.TrialData;
rawdata_offline = rawdata_offline.TrialData;

%rawdata = rawdata;
%rawdata = rawdata_offline;
%rawdata = rawdata_comparison;
%% 闁插洭娉﹂崣鍌涙殶閿涘本鐎铏圭崶閸??
sample_frequency = 256; 
WindowLength = 512;  
SlideWindowLength = 256;  
Trigger = double(rawdata(end,:)); 

% 初始化空列表来存储数据
DataSampleMI_Drinking = [];
DataSampleMI_Pouring = [];

% 闂堟瑦浼呴幀浣规殶閹??
class_index = 6;
RawDataIdle = double(rawdata(1:end-1, Trigger == class_index));  % 閹绘劕褰囨潻娆庣缁崵娈戦棃娆愪紖閹焦鏆熼幑?
FilteredDataIdle = DataFilter(RawDataIdle, sample_frequency);  % 濠娿倖灏濋崢璇叉珨
[windows_per_session, SampleDataPre] = WindowsDataPre(FilteredDataIdle, WindowLength, SlideWindowLength);
[DataSampleIdle, ] = DataWindows(SampleDataPre, FilteredDataIdle, channels, class_index, windows_per_session, SlideWindowLength, WindowLength);

% 遍历所有数据点
for i = WindowLength+1:length(Trigger)
    % 检查当前Trigger是否为7（休息时间）
    if Trigger(i) == 7
        % 回溯并提取前512个数据点
        window_data = rawdata(:, (i-WindowLength):i-1);
        
        % 检查这512个数据点中的Trigger是否为1或2
        result_ = all(window_data(end, :) == 1);
        if all(window_data(end, :) == 1)
            class_index = 1;
            RawDataMI = double(window_data(1:end-1, window_data(end, :) == class_index));
            FilteredDataMI = DataFilter(RawDataMI, sample_frequency);
            [windows_per_session, SampleDataPre] = WindowsDataPre(FilteredDataMI, WindowLength, SlideWindowLength);
            [DataSample, ~] = DataWindows(SampleDataPre, FilteredDataMI, channels, class_index, windows_per_session, SlideWindowLength, WindowLength);
            DataSampleMI_Drinking = [DataSampleMI_Drinking, DataSample];
        elseif all(window_data(end, :) == 2)
            class_index = 2;
            RawDataMI = double(window_data(1:end-1, window_data(end, :) == class_index));
            FilteredDataMI = DataFilter(RawDataMI, sample_frequency);
            [windows_per_session, SampleDataPre] = WindowsDataPre(FilteredDataMI, WindowLength, SlideWindowLength);
            [DataSample, ~] = DataWindows(SampleDataPre, FilteredDataMI, channels, class_index, windows_per_session, SlideWindowLength, WindowLength);
            DataSampleMI_Pouring = [DataSampleMI_Pouring, DataSample];
        end
    end
end
%% 鐠侊紕鐣籔SD閸ユ拝绱濋獮鏈电瑬缂佹ê鍩楁径鎾劥閼存垹鏁搁崷鏉胯埌閸??
% 濮ｅ繋绔存稉顏冩眽閻ㄥ嚤SD閸у洤?鐓庣摠閸岊煉绱濆ù瀣槸娴狅絿鐖滄潻娆撳櫡閸欘亝婀侀幋鎴滅娑??
Idle_all = zeros(channels_num, 1);
MIDrinking_all = zeros(channels_num, 1);
MIPouring_all = zeros(channels_num, 1);

% 鐠侊紕鐣籌dle閻ㄥ嫮鏁ゆ禍搴濈稊娑撳搫鐔?缁??
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

% 鐠侊紕鐣籑I_Drinking閻劋绨紒妯哄煑
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

% 鐠侊紕鐣籑I_Pouring閻劋绨紒妯哄煑
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

% 缂佹ê鍩楁径鎾劥閼存垹鏁搁崷鏉胯埌閸??
topo_painting = MIPouring_all-Idle_all;
topoplot([topo_painting; -1;-1;-1;-1],'Cap30.locs','maplimits',[-1.0,1.0], 'electrodes', 'on', 'style', 'map');


%% 閸忔湹缍戦崙鑺ユ殶闁劌鍨庨敍灞藉瘶閹奉剚鎶ゅ▔顫??浣稿灊缁愭鍤遍弫?
% 濠娿倖灏濋崙鑺ユ殶
function FilteredData = DataFilter(RawData, sample_frequency) 
    FilterOrder = 4;  % 鐠佸墽鐤嗙敮锕??姘姢濞夈垹娅掗惃鍕▉閺??
    NotchFilterOrder = 2;  % 鐠佸墽鐤嗛梽閿嬪皾濠娿倖灏濋崳銊ф畱闂冭埖鏆熼敍鍫ｇ箹闁插奔濞囬悽銊ュ弽閻楄鐭侀弬顖氱敨闂冪粯鎶ゅ▔銏犳珤閿??
    %Wband = [3,50];  % 濠娿倖灏濋崳銊ㄧ箹鏉堝綊娓剁憰浣稿棘閼板啰娴夐崗宕囨畱閺傚洨灏炴潻娑滎攽娣囶喗鏁奸敍宀冪箹闁插苯寮懓鍐у尃閺勭喎绗?婵劗娈戠拋鐑樻瀮娑擃厾娈戝銈嗗皾閸ｃ劏顔曠純?
    Wband = [8,12];
    Wband_notch = [49,51];
    FilterType = 'bandpass';
    FilterTypeNotch = 'stop';  % matlab閻ㄥ垺utter閸戣姤鏆熼柌宀勬桨閿涘矁顔曠純?'stop'娴兼俺鍤滈崝銊啎缂冾喗鍨?2闂冭埖鎶ゅ▔銏犳珤

    % 娴ｈ法鏁ら梽閿嬪皾濠娿倖灏濋崳銊ュ箵闂勩倕浼愭０鎴濇珨婢??
    FilteredData = Rsx_ButterFilter(NotchFilterOrder,Wband_notch,sample_frequency,FilterTypeNotch,RawData,size(RawData,1));
    % 娴ｈ法鏁ょ敮锕??姘姢濞夈垹娅掗崢濠氭珟閸ｎ亜锛?
    FilteredData = Rsx_ButterFilter(FilterOrder,Wband,sample_frequency,FilterType,FilteredData,size(FilteredData,1)); 
end

% 鐠侊紕鐣婚崚鎺旂崶閻ㄥ嫬鍤遍弫?
function [windows_per_session, DataSamplePre] = WindowsDataPre(RawData, WindowLength, SlideWindowLength)
    data_points_per_session = size(RawData,2);  % 濮ｅ繋绔存稉鐚籩ssion閻ㄥ嫭鏆熼幑顕?鍣?
    % seconds_per_session  = size(EIRawData,2)/sample_frequency;  % 濮ｅ繋绔存稉鐚籩ssion閻ㄥ嫭妞傞梻鎾毐鎼??

    windows_per_session = (data_points_per_session - WindowLength) / SlideWindowLength + 1;  % session濠婃垹鐛ラ崥搴ｆ畱缁愭鏆熼柌?

    % shape: (1, number of windows in this session)
    DataSamplePre = cell(1, windows_per_session);
end

% 閸掓帞鐛ラ崙鑺ユ殶
function [DataSample, LabelWindows] = DataWindows(DataSamplePre, FilteredData, channels, class_index, windows_per_session, SlideWindowLength, WindowLength, sample_frequency)
    % channels = [3:32]; 
    % channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; 
    % channels = [3,8,27,28,30,31,32,33]-1;  % 绾喖鐣鹃崜宥夘杺閸欏墎娈戦柅姘朵壕閿涘瞼鏁辨禍搴ゎ唶瑜版洜娈戞穱鈥冲娇CH-1閺勭柖rigger閿涘本澧嶆禒銉﹀閺堝娈戠槐銏犵穿閸戝繐骞?1
    LabelWindows = [];
    % scores = [];  % 閻劋绨?涙ê鍋峴cores閸掑棙鏆熼惃鍕殶缂??

    % 閻㈢喐鍨氶崚鎺旂崶閻ㄥ嫭鏆熼幑?
    for i = 1:windows_per_session
        PointStart = (i-1)*SlideWindowLength;  % 閸︺劍鏆熼幑顔昏厬绾喖鐣剧挧宄邦潗閻??
        DataSamplePre{1, i} = FilteredData(channels, PointStart + 1:PointStart + WindowLength );  % 閻㈢喐鍨氶崚鎺旂崶閻ㄥ嫬鍘撶粊?
        LabelWindows = [LabelWindows; class_index];  % 閻㈢喐鍨氱憗鍗╝bel閻ㄥ嫭鏆熼幑?
    end
    DataSample = DataSamplePre;
end