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
% init = 0;
% freq = 256;
% startStop = 1;
% con = pnet('tcpconnect','127.0.0.1',4455);                                 % ����һ������
% status = CheckNetStreamingVersion(con);                                    % �жϰ汾��Ϣ����ȷ����״ֵ̬Ϊ1
% [~, basicInfo] = ClientGetBasicMessage(con);                               % ��ȡ�豸������ϢbasicInfo���� size,eegChan,sampleRate,dataSize
% [~, infoList] = ClientGetChannelMessage(con,basicInfo.eegChan);            % ��ȡͨ����Ϣ

% %% ʵ����ز�������
% TrialNum = 10;                                                             % ���òɼ�������
% TrialIndex = randperm(TrialNum);                                           % ���ݲɼ��������������˳�������
% All_data = [];
% Trigger = 0;                                                               % ��ʼ��Trigger�����ں��������ݴ洢
% AllTrial = 0;
% 
% MotorClasses = 2;                                                          % �˶���������������������
% randomindex = [];                                                          % ��ʼ��trials�ļ���
% for i= 1:MotorClasses
%     index_i = ones(TrialNum/MotorClasses,1)*i;                             % size TrialNum/MotorClasses*1����������
%     randomindex = [randomindex; index_i];                                  % �����������ϣ�����size TrialNum*1
% end
% 
% RandomTrial = randomindex(TrialIndex);                                     % ������ɸ���Trial��Ӧ������

%% ���������ŵ���
session_idx = 1;

MotorClass = 2; % ע�������Ǵ���Ƶ��˶�������������������������idle״̬
MajorPoportion = 0.6;
TrialNum = 40;
DiffLevels = [2,1];

if session_idx == 1
    Level2task(MotorClass, MajorPoportion, TrialNum, DiffLevels);
    RandomTrial = load(['Online_EEGMI_session_', num2str(session_idx), '_', '.mat'],'session');
else
    RandomTrial = load(['Online_EEGMI_session_', num2str(session_idx), '_', '.mat'],'session');
end


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
%     tic
    pause(1);
%     [~, data] = ClientGetDataPacket(con,basicInfo,infoList,startStop,init); % Obtain EEG data, ��Ҫ��ClientGetDataPacket����Ҫ��Ҫ�Ƴ�����
%     toc
%     data = [data;TriggerRepeat];
%     TrialData = [TrialData,data];
    Timer = Timer + 1;
    
    if Timer == 13
        Timer = 0;  % ��ʱ����0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(RandomTrial(AllTrial))]);  % ��ʾ�������
    end
    
end
%% �洢����
% close all
% TrialData = TrialData(2:end,:);  %ȥ�������һ��
% ChanLabel = flip({infoList.chanLabel});
% pnet('closeall')   % �����ӹر�
% 
% save(FunctionNowFilename('Offline_EEGdata_', '.mat' ),'TrialData','TrialIndex','ChanLabel');

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
            session = [session, repmat(MotorMinor, 1, NumMinor)];  % ����ʣ�µĶ���
        end    
        session = [session, repmat(0, 1, NumMinor)];  % ���Ӻ�ʣ�¶���һ�±����Ŀ��붯��
        save(['Online_EEGMI_session_', num2str(SessionIndex), '_', '.mat'],'session');  % �洢������ݣ�����洢��
    end
    
end