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
system('E:\MI_engagement\unity_test\unity_test\build_test\unity_test.exe&');
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

%% ���������ŵ���
Trigger = 0;                                                               % ��ʼ��Trigger�����ں��������ݴ洢
AllTrial = 0;

session_idx = 1;

MotorClass = 3; % ע�������Ǵ���Ƶ��˶�������������������������idle״̬
MajorPoportion = 0.6;
TrialNum = 40;
DiffLevels = [2,1,3];

if session_idx == 1  % ����ǵ�һ��session������Ҫ������ص����񼯺�
    Level2task(MotorClass, MajorPoportion, TrialNum, DiffLevels);
    RandomTrial = load(['Online_EEGMI_session_', num2str(session_idx), '_', '.mat'],'session');
else
    RandomTrial = load(['Online_EEGMI_session_', num2str(session_idx), '_', '.mat'],'session');
end

%% ��ʼʵ�飬���߲ɼ�
Timer = 0;
TrialData = [];
MaxMITime = 30; % �����˶������������ʱ�� 
sample_frequency = 256; 
WindowLength = 512;  % ÿ�����ڵĳ���
channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��
mu_channel = 14;  % ���ڼ���ERD/ERS�ļ���channels����Ҫȷ����λ�õ�
EI_channel = 10;  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�
weight_mu = 0.6;  % ���ڼ���ERD/ERSָ���EIָ��ļ�Ȩ��
scores = [];  % ���ڴ洢ÿһ��trial����ķ���ֵ
scores_trial = [];  % ���ڴ洢ÿһ��trial��ƽ������ֵ
ip = '172.18.22.21';
port = 8888;  % �ͺ�˷��������ӵ���������
clsFlag = 0; % �����ж�ʵʱ�����Ƿ���ȷ��flag
subject_name = 'Jyt';  % ���Ե�����  

while(AllTrial <= TrialNum)
    %% ��ʾרע�׶�
    if Timer==0  %��ʾרע cross
        Trigger = 6;
        sendbuf(1,1) = hex2dec('03') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);       
        AllTrial = AllTrial + 1;
    end
    
    %% �˶�����׶�
    if Timer==2
        if RandomTrial(AllTrial)==0  % ��������
            Trigger = 1;
            sendbuf(1,1) = hex2dec('01') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        if RandomTrial(AllTrial)==2  % �˶���������
            Trigger = 2;
            sendbuf(1,1) = hex2dec('02') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
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
    
    
    % ��2s��ʱ��ȡ512��Trigger==6�Ĵ��ڣ����ݴ����ҽ��з���
    if Timer == 2
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        % ���������ȡ��MI֮ǰ��Ƶ������
        [~, ~, mu_power_] = Online_DataPreprocess(rawdata, 6, sample_frequency, WindowLength, channels);       
    end
    
    % ��4s��ʼȡ512��Trigger~=6��MI�Ĵ��ڣ����ݴ����ҽ��з���
    if Timer > 3 & RandomTrial(AllTrial)~=0 & clsFlag == 0
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess(rawdata, RandomTrial(AllTrial), sample_frequency, WindowLength, channels);
        mu_suppression = (mu_power_MI(1,mu_channel) - mu_power_(1,mu_channel))/mu_power_(1,mu_channel);
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index;  % ����÷�
        scores = [scores, score];  % ����÷�
        config_data = [WindowLength, size(channels, 2), size(scores, 2), RandomTrial(AllTrial)];
        resultMI = Online_Data2Server_Communicate(1.0, FilteredDataMI, ip, port, subject_name, config_data);  % �������ݸ����ϵ�ģ�ͣ����������
        if resultMI == RandomTrial(AllTrial)
            clsFlag = 1;  % ʶ����ȷ����1
        else
            clsFlag = 0;
        end        
    end
    
   %% �˶�������뷴���׶Σ����/ʱ�䷶Χ��û����ԣ�,ͬʱ����ģ��
   % ����˿�ʼ���Ŷ��� 
   if clsFlag == 1 
        clsTime = Timer;  % ���Ƿ�����ȷ��ʱ��
        if RandomTrial(AllTrial)==2  % �˶���������
            Trigger = 2;
            sendbuf(1,1) = hex2dec('02') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % ����ռ����ڴ������ݺ͸���ģ��
        
   end
    
    % ����˿�ʼ��Ϣ������
    if clsFlag == 0 & Timer == (MaxMITime + 2)
        clsTime = Timer;  % ���Ƿ�����ȷ��ʱ��
        if RandomTrial(AllTrial)==2  % �˶���������
            Trigger = 2;
            sendbuf(1,1) = hex2dec('02') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % ����ռ����ڴ������ݺ͸���ģ��
        
    end
    
   %% ��Ϣ�׶Σ�ȷ����һ������
    % ����ֻ��5s����Ϣ
    if Timer==7 & RandomTrial(AllTrial)==0  %��ʼ��Ϣ
        Trigger = 6;
        sendbuf(1,1) = hex2dec('04') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % Ԥ���ռ䣬׼��д�����㷨��ȷ����һ������ĳ���
        
    end
    % �˶����������֮��AO������֮��������Ϣ
    if Timer == (clsTime + 5) & clsFlag == 1  %��ʼ��Ϣ
        Trigger = 6;
        sendbuf(1,1) = hex2dec('04') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % Ԥ���ռ䣬׼��д�����㷨��ȷ����һ������ĳ���
        
    end
    % �˶�����û����ԣ����ѽ�����֮��������Ϣ
    if clsFlag == 0 & Timer == (MaxMITime + 2 + 5)
        Trigger = 6;
        sendbuf(1,1) = hex2dec('04') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % Ԥ���ռ䣬׼��д�����㷨��ȷ����һ������ĳ���
        
    end
    %% ���ĸ�����ֵ��λ
    % ������������5s������7s֮��ʼ��Ϣ������10s�ͽ�������
    if Timer == 10 & RandomTrial(AllTrial)==0  %������Ϣ��׼����һ��
        Timer = 0;  % ��ʱ����0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(RandomTrial(AllTrial))]);  % ��ʾ�������
    end
    % �����֮��AO֮����Ϣ3s֮�󣬽�����Ϣ��׼����һ��
    if Timer == (clsTime + 5 + 3) & clsFlag == 1  %������Ϣ
        Timer = 0;  % ��ʱ����0
        clsFlag = 0;  % ����flag��0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(RandomTrial(AllTrial))]);  % ��ʾ�������
    end
    
    % �˶�����û����ԣ�����֮����Ϣ3s֮�󣬽�����Ϣ��׼����һ��
    if clsFlag == 0 & Timer == (MaxMITime + 2 + 5 + 3)
        Timer = 0;  % ��ʱ����0
        clsFlag = 0;  % ����flag��0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(RandomTrial(AllTrial))]);  % ��ʾ�������
    end
end
%% �洢ԭʼ����
close all
TrialData = TrialData(2:end,:);  %ȥ�������һ��
ChanLabel = flip({infoList.chanLabel});
pnet('closeall')   % �����ӹر�
save(FunctionNowFilename(['Offline_EEG_Rawdata_', subject_name],'.mat' ),'TrialData','TrialIndex','ChanLabel');

%% ����Ԥ����
% ������������
SlideWindowLength = 256;  % �������
[DataX, DataY, windows_per_session] = Offline_DataPreprocess(rawdata, classes, sample_frequency, WindowLength, SlideWindowLength, channels);
% Ԥ����֮������ݴ洢��������洫��ʧ�ܣ�ֱ�ӽ�������mat�ļ��͵���������
save(FunctionNowFilename(['Offline_EEG_data_', subject_name], '.mat' ),'DataX');
save(FunctionNowFilename(['Offline_EEG_label_', subject_name], '.mat' ),'DataY');

%% Ԥ�������ݴ���
% ���ô���Ĳ���
config_data = [WindowLength, size(channels, 2), windows_per_session, MotorClasses];
Offline_Data2Server_Send(DataX, ip, port, subject_name, config_data);


%% �����ʼ���ɵĺ���
function Level2task(MotorClasses, MajorPoportion, TrialNum, DiffLevels)  % MajorPoportion ÿһ��session�е���Ҫ�����ı�����TrailNum ÿһ��session�е�trial����, DiffLevels�ӵ͵��������Ѷȵľ��󣬾��������ֵԽ�߱�ʾ�Ѷ�Խ�� 
    
    for SessionIndex = 1:MotorClasses  % �����SessionIndexҲ����Ҫ�Ѷȶ�Ӧ��λ��
        session = [];
        MotorMain = DiffLevels(1, SessionIndex);  % ��Ҫ�ɷֵ��˶�
        NumMain = round(TrialNum * MajorPoportion);  
        session = [session, repmat(MotorMain, 1, NumMain)];
        
        indices = find(DiffLevels==MotorMain);  % �ҵ�MotorMain��Ӧ��index
        DiffLevels_ = DiffLevels;
        DiffLevels_(indices) = [];  % ȥ��MotorMain��ʣ�µ��ѶȾ���
        
        for i_=1:(MotorClasses - 1)
            MotorMinor = DiffLevels_(1, i_);  % ʣ�µļ�������
            MinorProportion =  (1-MajorPoportion)/(MotorClasses - 1);  % ʣ�¶����ı���
            NumMinor = ronud(TrialNum * MinorProportion);
            session = [session, repmat(MotorMinor, 1, NumMinor)];  % ���ʣ�µĶ���
        end    
        session = [session, repmat(0, 1, NumMinor)];  % ��Ӻ�ʣ�¶���һ�±����Ŀ��붯��
        save(['Online_EEGMI_session_', num2str(SessionIndex), '_', '.mat'],'session');  % �洢������ݣ�����洢��
    end
    
end