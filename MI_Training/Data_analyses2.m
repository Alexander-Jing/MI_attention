%% 琚瘯鍚嶇О鍜屽疄楠岀殑鏂囦欢澶?
subject_name_online =  'Jyt_test_0101_1_online'; % 'Jyt_test_0101_online';%'Jyt_test_0108_online'; %%  %  % 琚瘯濮撳悕
sub_online_collection_folder = 'Jyt_test_0101_1_online_20240101_200123314_data'; %'Jyt_test_0101_online_20240101_175129548_data';  % %'';%  %'Jyt_test_0108_online_20240110_000906267_data'; %   %''; %  % 
sub_online_rawdata_file = 'Online_EEGMI_RawData_1_Jyt_test_0101_1_online20240101_202349586.mat'; %'Online_EEGMI_RawData_1_Jyt_test_0101_online20240101_181405221';  %;;  

subject_name_offline =  'Jyt_test_0101_1_offline';  % 绂荤嚎鏀堕泦鏁版嵁鏃跺?欑殑琚瘯鍚嶇О
sub_offline_collection_folder = 'Jyt_test_0101_1_offline_20240101_193332077_data';  % 琚瘯鐨勭绾块噰闆嗘暟鎹?

%channels_preprocessing = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15, 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 閫夋嫨鐨勯?氶亾,
channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,  15, 16,17,18,19,  21,22,23,24,25,26,27,28,29,30,31,32];  % 鏁版嵁鍘绘帀M1鍜孧2
%channels = [1,2,3,4,5,6,7,8,9,10,11,12,13, 14, 15, 16,17,18,19, 20, 21,22,23,24,25,26,27,28,29,30,31,32];  % 鏁版嵁鍘绘帀M1鍜孧2

mu_channels = struct('C3',24, 'C4',22);  % 鐢ㄤ簬璁＄畻ERD/ERS鐨勫嚑涓猚hannels锛屾槸C3鍜孋4涓や釜閫氶亾,闇?瑕佽瀹氫綅缃?
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % 鐢ㄤ簬璁＄畻EI鎸囨爣鐨勫嚑涓猚hannels锛岄渶瑕佺‘瀹氫笅浣嶇疆鐨?
motorclasses = 3;
channels_num = length(channels);

%% 璇诲彇鏁版嵁
subject_rawdata_folder = ['.\', sub_online_collection_folder, '\' 'Online_EEGMI_RawData_', subject_name_online];
rawdata = load([subject_rawdata_folder, '\', sub_online_rawdata_file]);
rawdata_comparison = load('.\Jyt_test_0101_1_comparison_1_20240101_221830944_data\Offline_EEGMI_RawData_Jyt_test_0101_1_comparison_1\Offline_EEGMI_RawData_Jyt_test_0101_1_comparison_120240101_222612681.mat', 'TrialData');
rawdata_offline = load('.\Jyt_test_0101_offline_20240101_170352928_data\Offline_EEGMI_RawData_Jyt_test_0101_offline\Offline_EEGMI_RawData_Jyt_test_0101_offline20240101_171926945.mat', 'TrialData');
%load('F:\CASIA\MI_engagement\MI_attention\MI_Training\Jyt_test_0101_1_offline_20240101_193332077_data\Offline_EEGMI_RawData_Jyt_test_0101_1_offline\Offline_EEGMI_RawData_Jyt_test_0101_1_offline20240101_194900541.mat', 'TrialData');

rawdata = rawdata.TrialData;
rawdata_comparison = rawdata_comparison.TrialData;
rawdata_offline = rawdata_offline.TrialData;

rawdata = rawdata_comparison;
%rawdata = rawdata_offline;
%% 閲囬泦鍙傛暟锛屾瀯寤虹獥鍙?
sample_frequency = 256; 

WindowLength = 512;  % 姣忎釜绐楀彛鐨勯暱搴?
SlideWindowLength = 256;  % 婊戠獥闂撮殧

Trigger = double(rawdata(end,:)); %rawdata鏈?鍚庝竴琛
% 闈欐伅鎬佹暟鎹?
class_index = 6;
RawDataIdle = double(rawdata(1:end-1, Trigger == class_index));  % 鎻愬彇杩欎竴绫荤殑闈欐伅鎬佹暟鎹?
FilteredDataIdle = DataFilter(RawDataIdle, sample_frequency);  % 婊ゆ尝鍘诲櫔
[windows_per_session, SampleDataPre] = WindowsDataPre(FilteredDataIdle, WindowLength, SlideWindowLength);
[DataSampleIdle, ] = DataWindows(SampleDataPre, FilteredDataIdle, channels, class_index, windows_per_session, SlideWindowLength, WindowLength);

%杩愬姩鎯宠薄鏁版嵁1
class_index = 1;
RawDataMI_Drinking = double(rawdata(1:end-1, Trigger == class_index));  % 鎻愬彇杩欎竴绫荤殑杩愬姩鎯宠薄鏁版嵁
FilteredDataMI_Drinking = DataFilter(RawDataMI_Drinking, sample_frequency);  % 婊ゆ尝鍘诲櫔
[windows_per_session, SampleDataPre] = WindowsDataPre(FilteredDataMI_Drinking, WindowLength, SlideWindowLength);
[DataSampleMI_Drinking, ] = DataWindows(SampleDataPre, FilteredDataMI_Drinking, channels, class_index, windows_per_session, SlideWindowLength, WindowLength);

%杩愬姩鎯宠薄鏁版嵁2
class_index = 2;
RawDataMI_Pouring = double(rawdata(1:end-1, Trigger == class_index));  % 鎻愬彇杩欎竴绫荤殑杩愬姩鎯宠薄鏁版嵁
FilteredDataMI_Pouring = DataFilter(RawDataMI_Pouring, sample_frequency);  % 婊ゆ尝鍘诲櫔
[windows_per_session, SampleDataPre] = WindowsDataPre(FilteredDataMI_Pouring, WindowLength, SlideWindowLength);
[DataSampleMI_Pouring, ] = DataWindows(SampleDataPre, FilteredDataMI_Pouring, channels, class_index, windows_per_session, SlideWindowLength, WindowLength);

%% 璁＄畻PSD鍥撅紝骞朵笖缁樺埗澶撮儴鑴戠數鍦板舰鍥?
% 姣忎竴涓汉鐨凱SD鍧囧?煎瓨鍌紝娴嬭瘯浠ｇ爜杩欓噷鍙湁鎴戜竴涓?
Idle_all = zeros(channels_num, 1);
MIDrinking_all = zeros(channels_num, 1);
MIPouring_all = zeros(channels_num, 1);

% 璁＄畻Idle鐨勭敤浜庝綔涓哄熀绾?
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

% 璁＄畻MI_Drinking鐢ㄤ簬缁樺埗
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

% 璁＄畻MI_Pouring鐢ㄤ簬缁樺埗
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

% 缁樺埗澶撮儴鑴戠數鍦板舰鍥?
topo_painting = MIDrinking_all-Idle_all;
topoplot([topo_painting; -1;-1;-1;-1],'Cap30.locs','maplimits',[-1.0,1.0], 'electrodes', 'on', 'style', 'map');


%% 鍏朵綑鍑芥暟閮ㄥ垎锛屽寘鎷护娉?佸垝绐楀嚱鏁?
% 婊ゆ尝鍑芥暟
function FilteredData = DataFilter(RawData, sample_frequency) 
    FilterOrder = 4;  % 璁剧疆甯﹂?氭护娉㈠櫒鐨勯樁鏁?
    NotchFilterOrder = 2;  % 璁剧疆闄锋尝婊ゆ尝鍣ㄧ殑闃舵暟锛堣繖閲屼娇鐢ㄥ反鐗规矁鏂甫闃绘护娉㈠櫒锛?
    %Wband = [3,50];  % 婊ゆ尝鍣ㄨ繖杈归渶瑕佸弬鑰冪浉鍏崇殑鏂囩尞杩涜淇敼锛岃繖閲屽弬鑰冧匠鏄熷笀濮愮殑璁烘枃涓殑婊ゆ尝鍣ㄨ缃?
    Wband = [8,12];
    Wband_notch = [49,51];
    FilterType = 'bandpass';
    FilterTypeNotch = 'stop';  % matlab鐨刡utter鍑芥暟閲岄潰锛岃缃?'stop'浼氳嚜鍔ㄨ缃垚2闃舵护娉㈠櫒

    % 浣跨敤闄锋尝婊ゆ尝鍣ㄥ幓闄ゅ伐棰戝櫔澹?
    FilteredData = Rsx_ButterFilter(NotchFilterOrder,Wband_notch,sample_frequency,FilterTypeNotch,RawData,size(RawData,1));
    % 浣跨敤甯﹂?氭护娉㈠櫒鍘婚櫎鍣０
    FilteredData = Rsx_ButterFilter(FilterOrder,Wband,sample_frequency,FilterType,FilteredData,size(FilteredData,1)); 
end

% 璁＄畻鍒掔獥鐨勫嚱鏁?
function [windows_per_session, DataSamplePre] = WindowsDataPre(RawData, WindowLength, SlideWindowLength)
    data_points_per_session = size(RawData,2);  % 姣忎竴涓猻ession鐨勬暟鎹噺
    % seconds_per_session  = size(EIRawData,2)/sample_frequency;  % 姣忎竴涓猻ession鐨勬椂闂撮暱搴?

    windows_per_session = (data_points_per_session - WindowLength) / SlideWindowLength + 1;  % session婊戠獥鍚庣殑绐楁暟閲?

    % shape: (1, number of windows in this session)
    DataSamplePre = cell(1, windows_per_session);
end

% 鍒掔獥鍑芥暟
function [DataSample, LabelWindows] = DataWindows(DataSamplePre, FilteredData, channels, class_index, windows_per_session, SlideWindowLength, WindowLength, sample_frequency)
    % channels = [3:32]; 
    % channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; 
    % channels = [3,8,27,28,30,31,32,33]-1;  % 纭畾鍓嶉鍙剁殑閫氶亾锛岀敱浜庤褰曠殑淇″彿CH-1鏄疶rigger锛屾墍浠ユ墍鏈夌殑绱㈠紩鍑忓幓1
    LabelWindows = [];
    % scores = [];  % 鐢ㄤ簬瀛樺偍scores鍒嗘暟鐨勬暟缁?

    % 鐢熸垚鍒掔獥鐨勬暟鎹?
    for i = 1:windows_per_session
        PointStart = (i-1)*SlideWindowLength;  % 鍦ㄦ暟鎹腑纭畾璧峰鐐?
        DataSamplePre{1, i} = FilteredData(channels, PointStart + 1:PointStart + WindowLength );  % 鐢熸垚鍒掔獥鐨勫厓绁?
        LabelWindows = [LabelWindows; class_index];  % 鐢熸垚瑁卨abel鐨勬暟鎹?
    end
    DataSample = DataSamplePre;
end