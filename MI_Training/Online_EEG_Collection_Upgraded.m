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
%system('F:\CASIA\mwl_data_collection\climbstair\ClimbStair3.exe&');       % Unity����exe�ļ���ַ
%system('E:\MI_engagement\unity_test\unity_test\build_test\unity_test.exe&');
system('E:\MI_UpperLimb_AO\UpperLimb_AO\UpperLimb_AO\build_test\unity_test.exe&');
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
subject_name = 'Jyt_test';  % ��������
sub_offline_collection_folder = 'Jyt_test_data';  % ���Ե����߲ɼ�����
session_idx = 1;  % session index�����������1�Ļ������Զ���������Ų�
MotorClass = 2; % �˶�������������ע�������Ǵ���Ƶ��˶�������������������������idle״̬
DiffLevels = [1,2];  % ����������˶�������Ѷ��Ų���Խ����Խ�ѣ����е�1,2��Ӧ�����˶���������ͣ���unity��Ӧ
MajorPoportion = 0.6;  % ÿһ��session���治ͬ�����˶�����������ռ�ı�ֵ
TrialNum = 40;  % ÿһ��session�����trial������

% �˶����������������
score_init = 1.0;  % ������֮ǰ����ʱ������mu˥����EIָ��ľ�ֵ
MaxMITime = 30; % �����˶������������ʱ�� 
sample_frequency = 256; 
WindowLength = 512;  % ÿ�����ڵĳ���
channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��
mu_channels = struct('C3',1, 'C4',2);  % ���ڼ���ERD/ERS�ļ���channels����C3��C4����ͨ��,��Ҫ�趨λ��
EI_channels = struct('Fp1', 1, 'Fp2', 2, 'F7', 3, 'F3', 4, 'Fz', 5, 'F4', 6, 'F8', 7);  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�
weight_mu = 0.6;  % ���ڼ���ERD/ERSָ���EIָ��ļ�Ȩ��
MI_MUSup_thre = 0;  % ����MIʱ�����ֵ��ʼ��
MI_MUSup_thre_weight_baseline = 0.8;  % ���ڼ���MIʱ���mu˥������ֵȨ�س�ʼ����ֵ�����Ȩ��һ���Ǻͷ���ĸ�����صģ�Ҳ������������ݽ��е���
MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline;  % ���ڼ���MIʱ���mu˥������ֵȨ����ֵ�����Ȩ��һ���Ǻͷ���ĸ�����صģ�Ҳ������������ݽ��е���

% ͨ������
ip = '172.18.22.21';
port = 8888;  % �ͺ�˷��������ӵ���������

%% ׼����ʼ�Ĵ洢���ݵ��ļ���
foldername = ['.\\', FunctionNowFilename([subject_name, '_'], '_data')]; % ָ���ļ���·��������
if ~exist(foldername, 'dir')
   mkdir(foldername);
end

%% ����mu˥����׷�ٹ켣
% ��ȡ֮ǰ�����߲ɼ�������
foldername_Scores = [foldername, '\\Offline_EEGMI_Scores_', subject_name]; % ָ��֮ǰ�洢�������ļ���·��������
mean_std_EI = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name], '.mat' ], 'mean_std_EI');
mean_std_muSup = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name], '.mat' ], 'mean_std_muSup');

% �������ڵĹ켣
traj = generate_traj(mean_std_muSup, TrialNum);

%% �˶��������ݰ���
TrialIndex = randperm(TrialNum);                                           % ���ݲɼ��������������˳�������
%All_data = [];
Trigger = 0;                                                               % ��ʼ��Trigger�����ں��������ݴ洢
AllTrial = 0;

randomindex = [];                                                          % ��ʼ��trials�ļ���
for i= 1:(MotorClasses)                                                    % ע�⣬����ֻ�����˶���������񣬺��������ʵ�����������صľ�Ϣ״̬
    index_i = ones(TrialNum/MotorClasses,1)*i;                             % size TrialNum/MotorClasses*1����������
    randomindex = [randomindex; index_i];                                  % �����������ϣ�����size TrialNum*1
end

RandomTrial = randomindex(TrialIndex);                                     % ������ɸ���Trial��Ӧ������

%% ��ʼʵ�飬���߲ɼ�
Timer = 0;
TrialData = [];
scores = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window�ķ���ֵ
EI_indices = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window��EI����ֵ
mu_powers = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window��muƵ����������ֵ
scores_trial = [];  % ���ڴ洢ÿһ��trial��ƽ������ֵ
mu_suppressions = [];  % ���ڴ洢mu_suppression
clsFlag = 0; % �����ж�ʵʱ�����Ƿ���ȷ��flag
clsTime = 100;  % ��ʼ��������ȷ��ʱ��
RestTimeLenBaseline = 3 + session_idx;  % ��Ϣʱ������session����������
RestTimeLen = RestTimeLenBaseline;  % ��ʼ����Ϣʱ��
Trials = RandomTrial;

while(AllTrial <= TrialNum)
    %% ��ʾרע�׶�
    if Timer==0  %��ʾרע cross
        Trigger = 6;
        sendbuf(1,1) = hex2dec('01') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);       
        AllTrial = AllTrial + 1;
    end
    
    %% �˶�����׶�
    if Timer==2
        if Trials(AllTrial)==0  % ��������
            Trigger = 1;
            sendbuf(1,1) = hex2dec('03') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        if Trials(AllTrial)> 0  % �˶���������
            Trigger = Trials(AllTrial);  % ���Ŷ�����AO������Idle, MI1, MI2��
            mat2unity = ['0', num2str(Trigger + 3)];
            sendbuf(1,1) = hex2dec(mat2unity) ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % ��2s��ʱ��ȡ512��Trigger==6�Ĵ��ڣ����ݴ����ҽ��з���
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        % ���������ȡ��MI֮ǰ��Ƶ������
        [~, ~, mu_power_] = Online_DataPreprocess(rawdata, 6, sample_frequency, WindowLength, channels);
        mu_power_ = [mu_power_; Trigger];
        mu_powers = [mu_powers, mu_power_];  % �����ص�mu��������

        % ȷ����һ�ֵ���ֵ
        Trigger_num_ = count_trigger(Trials, Trigger);
        MI_MUSup_thre = traj{Trigger_num_}(Trigger_num_);  % ������ֵ
        % ȷ����Ȩ֮�����ֵ
        MI_MUSup_thre = MI_MUSup_thre_weight * MI_MUSup_thre;
        % threshold ���ݴ��������Լ���ʾ
       sendbuf(1,6) = uint8((MI_MUSup_thre));
       fwrite(UnityControl,sendbuf);  
    end
    
    % ��4s��ʼȡ512��Trigger~=6��MI�Ĵ��ڣ����ݴ����ҽ��з���
    if Timer > 3 && Trials(AllTrial)> 0 && clsFlag == 0
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess(rawdata, Trials(AllTrial), sample_frequency, WindowLength, channels);
        % ��������ָ��
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % ����÷�
        scores = [scores, score];  % ����÷�

        % ���͵÷��Լ�һϵ������
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score(1,1);0;0;0;0 ];
        order = 1.0;
        resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data, foldername);  % �������ݸ����ϵ�ģ�ͣ����������
        
        % �÷�����ʵʱ��ʾ
        visual_feedback = (resultMI * mu_suppression)/MI_MUSup_thre;
        sendbuf(1,5) = uint8((visual_feedback*100.0));
        fwrite(UnityControl,sendbuf);
           
        % �ж��Ƿ���Ҫ��
        if resultMI * mu_suppression > MI_MUSup_thre
            clsFlag = 1;  % ʶ����ȷ����1
        else
            clsFlag = 0;
        end

%         if resultMI == Trials(AllTrial)
%             clsFlag = 1;  % ʶ����ȷ����1
%         else
%             clsFlag = 0;
%         end   

        % �洢��һϵ��ָ�����ֵ
        EI_index = [EI_index; Trigger];
        mu_power_MI = [mu_power_MI; Trigger];  % ���������Trigger�������ֵ������洢
        mu_suppression = [mu_suppression; Trigger]; % ���������Trigger�������ֵ������洢

        EI_indices = [EI_indices, EI_index];  % �����ص�EIָ����ֵ  
        mu_powers = [mu_powers, mu_power_MI];  % �����ص�mu��������
        mu_suppressions = [mu_suppressions, mu_suppression];  % �����ص�mu˥����������ں����ķ���
    end
    
   %% �˶�������뷴���׶Σ����/ʱ�䷶Χ��û����ԣ�,ͬʱ����ģ��
   % ����˿�ʼ���Ŷ��� 
   if clsFlag == 1 
        clsTime = Timer;  % ���Ƿ�����ȷ��ʱ��
        if Trials(AllTrial) > 0  % �˶���������
            Trigger = Trials(AllTrial);  % ���Ŷ�����AO������Idle, MI1, MI2��
            mat2unity = ['0', num2str(Trigger + 3)];
            sendbuf(1,1) = hex2dec(mat2unity);
            sendbuf(1,2) = hex2dec('01') ;
            sendbuf(1,3) = hex2dec('01') ;  % ���뷴������ʾ����
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % �������ݺ͸���ģ��
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score;0;0;0;0 ];
        order = 2.0;  % �������ݺ�ѵ��������
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
   end
    
    % ����˿�ʼ��Ϣ������
    if clsFlag == 0 && Timer == (MaxMITime)
        if Trials(AllTrial) > 0  % �˶���������
            Trigger = Trials(AllTrial);  % ���Ŷ�����AO������Idle, MI1, MI2��
            mat2unity = ['0', num2str(Trigger + 3)];
            sendbuf(1,1) = hex2dec(mat2unity);
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('02') ;  % ���뷴������ʾ����
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % �������ݺ͸���ģ��
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score(1,1);0;0;0;0 ];
        order = 2.0;  % �������ݺ�ѵ��������
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
    end
    
   %% ��Ϣ�׶Σ�ȷ����һ������
    % ����ֻ��5s����Ϣ
    if Timer==7 && Trials(AllTrial)==0  %��ʼ��Ϣ
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % �����㷨
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score(1,1);0;0;0;0 ];
        order = 2.0;  % �������ݺ�ѵ��������
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
        % ����ȷ����һ������
        average_score = average(EI_indices(1, :));  % ���ﻻ��EIָ�꣬�������ܻ��ỻ
        scores_trial = [scores_trial, average_score];  % �洢��ƽ���ķ���
        [Trials, MI_MUSup_thre_weight, RestTimeLen] = TaskAdjustUpgraded(scores_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline);
    end
    
    % �˶����������֮��AO������֮��������Ϣ
    if Timer == (clsTime + 5) && clsFlag == 1  %��ʼ��Ϣ
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % ����ȷ����һ������
        average_score = average(EI_indices(1, :));  % ���ﻻ��EIָ�꣬�������ܻ��ỻ
        scores_trial = [scores_trial, average_score];  % �洢��ƽ���ķ���
        [Trials, MI_MUSup_thre_weight, RestTimeLen] = TaskAdjustUpgraded(scores_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline);
    end
    
    % �˶�����û����ԣ����ѽ�����֮��������Ϣ
    if clsFlag == 0 && Timer == (MaxMITime + 3)
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % ����ȷ����һ������
        average_score = average(EI_indices(1, :));  % ���ﻻ��EIָ�꣬�������ܻ��ỻ
        scores_trial = [scores_trial, average_score];  % �洢��ƽ���ķ���
        [Trials, MI_MUSup_thre_weight, RestTimeLen] = TaskAdjustUpgraded(scores_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline);
    end
    
    %% ʱ�Ӹ���
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
    
    %% ���ĸ�����ֵ��λ
    % ������������5s������7s֮��ʼ��Ϣ������10s�ͽ�������
    if Timer == 10 && Trials(AllTrial)==0  %������Ϣ��׼����һ��
        % �洢��ص�EIָ���mu��������������
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data);
        %��ʱ����0
        Timer = 0;  % ��ʱ����0
        % ÿһ��trial����ֵ��ԭ
        scores = [];  % ����ֵ��ԭ
        EI_indices = [];  % EI����ֵ��ԭ
        mu_powers = [];  % muƵ����������ֵ��ԭ
        RestTimeLen = 3;  % ��Ϣʱ�仹ԭ
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % ��ʾ�������
    end
    % �����֮��AO֮����Ϣ3s֮�󣬽�����Ϣ��׼����һ��
    if Timer == (clsTime + 5 + RestTimeLen) && clsFlag == 1  %������Ϣ
        % �洢��ص�EIָ���mu��������������
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data);
        % ��ʱ����0
        Timer = 0;  % ��ʱ����0
        % clsflag��0
        clsFlag = 0;  % ����flag��0
        % ÿһ��trial����ֵ��ԭ
        scores = [];  % ����ֵ��ԭ
        EI_indices = [];  % EI����ֵ��ԭ
        mu_powers = [];  % muƵ����������ֵ��ԭ
        % �������û�ԭ
        RestTimeLen = 3;  % ��Ϣʱ�仹ԭ
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % ��ʾ�������
    end
    % �˶�����û����ԣ�����֮����Ϣ3s֮�󣬽�����Ϣ��׼����һ��
    if clsFlag == 0 && Timer == (MaxMITime + 3 + RestTimeLen)
        % �洢��ص�EIָ���mu��������������
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data);
        % ��ʱ����0
        Timer = 0;  % ��ʱ����0
        % clsflag��0
        clsFlag = 0;  % ����flag��0
        % ÿһ��trial����ֵ��ԭ
        scores = [];  % ����ֵ��ԭ
        EI_indices = [];  % EI����ֵ��ԭ
        mu_powers = [];  % muƵ����������ֵ��ԭ
        % �������û�ԭ
        RestTimeLen = 3;  % ��Ϣʱ�仹ԭ
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % ��ʾ�������
    end
end
%% �洢ԭʼ����
close all
TrialData = TrialData(2:end,:);  %ȥ�������һ��
ChanLabel = flip({infoList.chanLabel});
pnet('closeall')   % �����ӹر�
% �洢ԭʼ����
foldername_rawdata = [foldername, '\\Online_EEGMI_RawData_', subject_name]; % ָ���ļ���·��������
if ~exist(foldername_rawdata, 'dir')
   mkdir(foldername_rawdata);
end
save([foldername_rawdata, '\\', FunctionNowFilename(['Online_EEGMI_RawData_',str(session_idx), '_', subject_name], '.mat' )],'TrialData','Trials','ChanLabel');

%% �洢���˶���������еĲ����ָ��
function SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data)
    
    foldername = [foldername, '\\Offline_Engagements_', subject_name]; % �����ļ����Ƿ����
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end

    save([foldername, '\\', FunctionNowFilename(['Online_EEG_data2Server_', subject_name, '_class_', num2str(config_data(3,1)),  ...
        '_session_', num2str(config_data(4,1)), '_trial_', num2str(config_data(5,1)), ...
        '_window_', num2str(config_data(6,1)), 'EI_mu' ], '.mat' )],'EI_indices',' mu_powers','mu_suppressions');  % �洢��ص���ֵ
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

%% ���ɹ켣�ĺ���
function traj = generate_traj(mean_std_muSup, TrialNum)
    % ��ȡ��������
    n = size(mean_std_muSup, 2);

    % ��ʼ��һ���յ� cell �������洢ÿ�����Ĺ켣
    traj = cell(1, n);

    % ����ÿһ�����
    for i = 1:n
        % ��ȡ mean �� std
        mean_val = mean_std_muSup(1, i);
        std_val = mean_std_muSup(2, i);

        % ��ʼ��һ���յ��������洢�켣
        traj{i} = zeros(TrialNum, 1);

        % ����켣
        for x = 1:TrialNum
            traj{i}(x) = mean_val + (std_val) * (1 - exp(-0.95 * x / TrialNum));
        end
    end
end
% Trials�����жϵ�ǰ����Ѿ����ֹ����ٴεĺ��������ھ�ϸ�Ĺ켣����
function count = count_trigger(Trials, AllTrial)
    % ��ȡ Trigger
    Trigger = Trials(AllTrial);
    
    % ���� Trigger �� Trials(1:AllTrial-1) �е�����
    count = sum(Trials(1:AllTrial-1) == Trigger);
end
