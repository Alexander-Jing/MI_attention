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

%% ʵ����ز�������
TrialNum = 10;                                                             % ���òɼ�������
TrialIndex = randperm(TrialNum);                                           % ���ݲɼ��������������˳�������
All_data = [];
Trigger = 0;                                                               % ��ʼ��Trigger�����ں��������ݴ洢
AllTrial = 0;

MotorClasses = 2;                                                          % �˶���������������������
randomindex = [];                                                          % ��ʼ��trials�ļ���
for i= 1:MotorClasses
    index_i = ones(TrialNum/MotorClasses,1)*i;                             % size TrialNum/MotorClasses*1����������
    randomindex = [randomindex; index_i];                                  % �����������ϣ�����size TrialNum*1
end

RandomTrial = randomindex(TrialIndex);                                     % ������ɸ���Trial��Ӧ������
%% ��ʼʵ�飬���߲ɼ�
Timer = 0;
TrialData = [];
while(AllTrial <= TrialNum)
    if Timer==0  %��ʾרע cross
        Trigger = 6;
        sendbuf(1,1) = hex2dec('03') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);       
        AllTrial = AllTrial + 1;
    end
    if Timer==2
        if RandomTrial(AllTrial)==1  % ��������
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
    if Timer==10  %��ʼ��Ϣ
        Trigger = 6;
        sendbuf(1,1) = hex2dec('04') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
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
    
    if Timer == 13
        Timer = 0;  % ��ʱ����0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(RandomTrial(AllTrial))]);  % ��ʾ�������
    end
    
end
%% �洢ԭʼ����
close all
TrialData = TrialData(2:end,:);  %ȥ�������һ��
ChanLabel = flip({infoList.chanLabel});
pnet('closeall')   % �����ӹر�
subject_name = 'Jyt'
save(FunctionNowFilename(['Offline_EEG_Rawdata_', subject_name],'.mat' ),'TrialData','TrialIndex','ChanLabel');

%% ����Ԥ����
% ������������
sample_frequency = 256; 
WindowLength = 512;  % ÿ�����ڵĳ���
SlideWindowLength = 256;  % �������
channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��
[DataX, DataY, windows_per_session] = Offline_DataPreprocess(rawdata, classes, sample_frequency, WindowLength, SlideWindowLength, channels);
% Ԥ����֮������ݴ洢��������洫��ʧ�ܣ�ֱ�ӽ�������mat�ļ��͵���������
save(FunctionNowFilename(['Offline_EEG_data_', subject_name], '.mat' ),'DataX');
save(FunctionNowFilename(['Offline_EEG_label_', subject_name], '.mat' ),'DataY');

%% Ԥ�������ݴ���
% ���ô���Ĳ���
ip = '172.18.22.21';
port = 8888;
config_data = [WindowLength, size(channels, 2), windows_per_session, MotorClasses];
Offline_Data2Server_Send(DataX, ip, port, subject_name, config_data);