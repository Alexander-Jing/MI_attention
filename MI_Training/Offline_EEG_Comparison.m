%% ��ʼ�����ر���������
pnet('closeall');
clc;
clear;
close all;
%% ����Unity���򣬲���ʼ��
% ����˵�����������5�ֽ�
%           Byte1������/�����л�
%           Byte2�����ƻ����Ƿ��˶�
%           Byte3������������ʾ������ѵ��ʵ����������ʾ��
%           Byte4����������
%           Byte5��Ԥ��
%system('F:\CASIA\mwl_data_collection\climbstair\ClimbStair3.exe&');      % Unity����exe�ļ���ַ
%system('E:\MI_engagement\unity_test\unity_test\build_test\unity_test.exe&');
%system('E:\UpperLimb_Animation\unity_test.exe&');
system('E:\UpperLimb_Animation\unity_test.exe&');
pause(3)
UnityControl = tcpip('localhost', 8881, 'NetworkRole', 'client');          % �µĶ˿ڸ�Ϊ8881
fopen(UnityControl);
pause(1)
sendbuf = uint8(1:5);
sendbuf(1,1) = hex2dec('00') ;
sendbuf(1,2) = hex2dec('00') ;
sendbuf(1,3) = hex2dec('00') ;
sendbuf(1,4) = hex2dec('00') ;
sendbuf(1,5) = hex2dec('00') ;
fwrite(UnityControl,sendbuf);
pause(3)

%% �����Ե�ɼ�����
init = 0;
freq = 256;
startStop = 1;
con = pnet('tcpconnect','127.0.0.1',4455);                                 % ����һ������
status = CheckNetStreamingVersion(con);                                    % �жϰ汾��Ϣ����ȷ����״ֵ̬Ϊ1
[~, basicInfo] = ClientGetBasicMessage(con);                               % ��ȡ�豸������ϢbasicInfo���� size,eegChan,sampleRate,dataSize
[~, infoList] = ClientGetChannelMessage(con,basicInfo.eegChan);            % ��ȡͨ����Ϣ

%% ����ʵ��������ò��֣���������ÿһ�����Ե���������ݱ�����������޸�

% �˶����������������
subject_name = 'Jyt_test_0101_1_comparison_1';  % ��������
TrialNum = 30;  % ���òɼ�������
%TrialNum = 3*3;
MotorClasses = 2;  % �˶��������������������ã��Ա�ʵ���������[1,2]����readme.txt����Ķ�Ӧ
% ��ǰ���õ�����
% Idle 0   -> SceneIdle 
% MI1 1   -> SceneMI_Drinking 
% MI2 2   -> Scene_Milk 
% �ɴ����������õ��ֵ�
task_keys = {0, 1, 2};
task_values = {'SceneIdle', 'SceneMI_Drinking', 'Scene_Milk'};
task_dict = containers.Map(task_keys, task_values);

% �Ե��豸�����ݲɼ�
sample_frequency = 256; 
WindowLength = 512;  % ÿ�����ڵĳ���
channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��,
mu_channels = struct('C3',24, 'C4',22);  % ���ڼ���ERD/ERS�ļ���channels����C3��C4����ͨ��,��Ҫ�趨λ��
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�
weight_mu = 0.6;  % ���ڼ���ERD/ERSָ���EIָ��ļ�Ȩ��

% ͨ������
ip = '172.18.22.21';
port = 8888;  % �ͺ�˷��������ӵ���������

% �Ѷȼ����뻮������
%task_weights = [3,5,2];

%% �˶��������ݰ���
TrialIndex = randperm(TrialNum);                                           % ���ݲɼ��������������˳�������
%All_data = [];
Trigger = 0;                                                               % ��ʼ��Trigger�����ں��������ݴ洢
AllTrial = 0;

randomindex = [];                                                          % ��ʼ��trials�ļ���
for i= 1:(MotorClasses)
    index_i = ones(TrialNum/MotorClasses,1)*i;                             % size TrialNum/MotorClasses*1����������
    randomindex = [randomindex; index_i];                                  % �����������ϣ�����size TrialNum*1
end

RandomTrial = randomindex(TrialIndex);                                     % ������ɸ���Trial��Ӧ������

%% ʵ�����ݲɼ��洢����
% ������ز���
classes = MotorClasses;
foldername = ['.\\', FunctionNowFilename([subject_name, '_'], '_data')]; % ָ���ļ���·��������

if ~exist(foldername, 'dir')
   mkdir(foldername);
end
% ���ô洢score������
scores = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window�ķ���ֵ
EI_indices = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window��EI����ֵ
EI_index_scores = [];  % ���ڴ洢EI_index_Caculation(EI_index, EI_channels)���������EI_index_score��ֵ
mu_powers = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window��muƵ����������ֵ
scores_task = [];  % ���ڴ洢score��task
mu_suppressions = [];  % ���ڴ洢mu_suppression

EI_index_scores_trialmean = [];  % ���ڴ洢ÿһ��trial�����EIָ���ֵ
mu_suppressions_trialmean = [];  % ���ڴ洢ÿһ��trial�����mu_suppressionsָ���ֵ
%% ��ʼʵ�飬���߲ɼ�
Timer = 0;
TrialData = [];
while(AllTrial < TrialNum)
    if Timer==0  %��ʾרע cross
        Trigger = 6;
        sendbuf(1,1) = hex2dec('01') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);       
        AllTrial = AllTrial + 1;
    end
    
    if Timer==2
        Trigger = RandomTrial(AllTrial);  % �л������棬���ǲ����Ŷ�����AO������Idle, MI1, MI2��
        mat2unity = ['0', num2str(Trigger + 3)];
        sendbuf(1,1) = hex2dec(mat2unity) ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        % ���������ȡ��MI֮ǰ��Ƶ������
        [~, ~, mu_power_] = Online_DataPreprocess(rawdata, 6, sample_frequency, WindowLength, channels);
        mu_power_ = [mu_power_; 6];
        mu_powers = [mu_powers, mu_power_];  % ������ص�mu��������
    end
    
    % ��4s��ʼȡ512��Trigger~=6��MI�Ĵ��ڣ����ݴ������ҽ��з���
    if Timer > 3 && Timer <= 7
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess(rawdata, Trigger, sample_frequency, WindowLength, channels);
        % mu_suppression = (mu_power_MI(mu_channel,1) - mu_power_(mu_channel,1))/mu_power_(mu_channel,1);  % ����miuƵ��˥�����
        % ��������ָ��
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % ����÷�
        scores = [scores, score];  % ����÷�
        scores_task_ = [score; Trigger];
        scores_task = [scores_task, scores_task_];  % �������-����ԣ����ں����ķ��������Ѷ��õ�
        
        % �洢�⼸��ָ�����ֵ
        EI_index_score = [EI_index_score; Trigger];
        EI_index = [EI_index; Trigger];
        mu_power_MI = [mu_power_MI; Trigger];  
        mu_suppression = [mu_suppression; Trigger]; % ����������Trigger�������ֵ������洢

        EI_index_scores = [EI_index_scores, EI_index_score];  % ������ص�EI_index_scores��ֵ��ע������Ǽ����˼���channelsͨ����ƽ����ֵ�������Ǹ�EI_indices�Ǵ洢��������ֵ
        EI_indices = [EI_indices, EI_index];  % ������ص�EIָ����ֵ�����ں����ķ���  
        mu_powers = [mu_powers, mu_power_MI];  % ������ص�mu�������������ں����ķ���
        mu_suppressions = [mu_suppressions, mu_suppression];  % ������ص�mu˥����������ں����ķ���
        
    end
    
    if Timer==7  %���Ŷ���
        sendbuf(1,2) = hex2dec('01') ;
        fwrite(UnityControl,sendbuf);
    end
    
    if Timer == (7+5)  % ����ʱ��5s
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        EI_index_scores_trialmean = [EI_index_scores_trialmean,[mean(EI_index_scores(1,end-4+1:end));RandomTrial(AllTrial)]];
        mu_suppressions_trialmean = [mu_suppressions_trialmean,[mean(mu_suppressions(1,end-4+1:end));RandomTrial(AllTrial)]];
    end
    
    % ���ɱ�ǩ
    TriggerRepeat = repmat(Trigger,1,256);  % ���ɱ�ǩ
    % �Ե��źŲɼ�
    tic
    pause(1);
    [~, data] = ClientGetDataPacket(con,basicInfo,infoList,startStop,init); % Obtain EEG data, ��Ҫ��ClientGetDataPacket����Ҫ��Ҫ�Ƴ�����
    toc
    data = [data;TriggerRepeat];
    TrialData = [TrialData,data];
    Timer = Timer + 1;
    
    if Timer == 15  % ��Ϣ3s
        Timer = 0;  % ��ʱ����0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(RandomTrial(AllTrial))]);  % ��ʾ�������
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % ����÷�
    end
    
end
%% �洢ԭʼ����
close all
TrialData = TrialData(2:end,:);  %ȥ�������һ��
ChanLabel = flip({infoList.chanLabel});
pnet('closeall')   % �����ӹر�
% �洢ԭʼ����
foldername_rawdata = [foldername, '\\Offline_EEGMI_RawData_', subject_name]; % ָ���ļ���·��������
if ~exist(foldername_rawdata, 'dir')
   mkdir(foldername_rawdata);
end
save([foldername_rawdata, '\\', FunctionNowFilename(['Offline_EEGMI_RawData_', subject_name], '.mat' )],'TrialData','TrialIndex','ChanLabel');

%% ����Ԥ����
% ������������
rawdata = TrialData;
sample_frequency = 256; 
WindowLength = 512;  % ÿ�����ڵĳ���
SlideWindowLength = 256;  % �������
[DataX, DataY, windows_per_session] = Offline_DataPreprocess(rawdata, classes, sample_frequency, WindowLength, SlideWindowLength, channels, subject_name, foldername);

%% ÿһ�������Ӧ�ĸ���ָ���ƽ������ȷ�������Ҵ洢���ָ��
foldername_Scores = [foldername, '\\Offline_EEGMI_Scores_', subject_name]; % ָ���ļ���·��������
if ~exist(foldername_Scores, 'dir')
   mkdir(foldername_Scores);
end
% �����������ָ��ľ�ֵ�ͷ���
%mean_std_EI = compute_mean_std(EI_indices);  
mean_std_muSup = compute_mean_std(mu_suppressions, 'mu_suppressions');  
mean_std_EI_score = compute_mean_std(EI_index_scores, 'EI_index_scores');
% �洢�������
save([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name], '.mat' ],'scores_task','EI_indices','mu_powers', ...
    'mu_suppressions','EI_index_scores', 'mean_std_EI_score','mean_std_muSup','EI_index_scores_trialmean','mu_suppressions_trialmean'); 

%% Ԥ�������ݴ���
% ���ô���Ĳ���
send_order = 3.0;
config_data = [WindowLength, size(channels, 2), windows_per_session, classes];
%Offline_Data2Server_Send(DataX, ip, port, subject_name, config_data, send_order, foldername);
%class_accuracies = Offline_Data2Server_Communicate(DataX, ip, port, subject_name, config_data, send_order, foldername);



%% ��ȡƽ������ȷ����ĺ���
function mean_std_scores = compute_mean_std(scores_task, scores_name)
    % ��ȡscores��triggers
    scores = scores_task(1,:);
    triggers = scores_task(2,:);

    % ��ȡ���в�ͬ��triggers
    unique_triggers = unique(triggers);

    % ��ʼ�����
    mean_scores = zeros(size(unique_triggers));
    std_scores = zeros(size(unique_triggers));

    % ����ÿһ��trigger�������Ӧ��score�ľ�ֵ
    for i = 1:length(unique_triggers)
        trigger = unique_triggers(i);
        mean_scores(i) = mean(scores(triggers == trigger));
        std_scores(i) = std(scores(triggers == trigger));
    end
    mean_std_scores = [mean_scores; std_scores];

    % ������
    disp(['ÿһ��Trigger��ƽ��', scores_name, '�����ǣ�']);
    for i = 1:length(unique_triggers)
        disp(['Trigger ' num2str(unique_triggers(i)) ' ��ƽ�������� ' num2str(mean_scores(i))]);
        disp(['Trigger ' num2str(unique_triggers(i)) ' �ı�׼���� ' num2str(std_scores(i))]);
    end
end
%% �������muƵ��˥��ָ��
function mu_suppresion = MI_MuSuperesion(mu_power_, mu_power, mu_channels)
        ERD_C3 = (mu_power(mu_channels.C3, 1) - mu_power_(mu_channels.C3, 1))/mu_power_(mu_channels.C3, 1); 
        ERD_C4 = (mu_power(mu_channels.C4, 1) - mu_power_(mu_channels.C4, 1))/mu_power_(mu_channels.C4, 1);  % ���������Ե�λ�õ���ص�ָ�� 
        mu_suppresion = abs(ERD_C4 - ERD_C3);
end
    
    %% ������ص�EIָ��ĺ���
function EI_index_score = EI_index_Caculation(EI_index, EI_channels)
    channels_ = [EI_channels.Fp1,EI_channels.Fp2, EI_channels.F7, EI_channels.F3, EI_channels.Fz, EI_channels.F4, EI_channels.F8'];
    EI_index_score = mean(EI_index(channels_, 1));

end