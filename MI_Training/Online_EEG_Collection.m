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
%% ����ʵ��������ò��֣���������ÿһ�����Ե���������ݱ�����������޸�

% �˶����������������
subject_name = 'Jyt';  % ��������
session_idx = 1;  % session index�����������1�Ļ������Զ���������Ų�
MotorClass = 2; % �˶�������������ע�������Ǵ���Ƶ��˶�������������������������idle״̬
DiffLevels = [2,1];  % ����������˶�������Ѷ��Ų���Խ����Խ�ѣ����е�1,2��Ӧ�����˶���������ͣ���unity��Ӧ
MajorPoportion = 0.6;  % ÿһ��session���治ͬ�����˶�����������ռ�ı�ֵ
TrialNum = 40;  % ÿһ��session�����trial������

% �˶����������������
MaxMITime = 30; % �����˶������������ʱ�� 
sample_frequency = 256; 
WindowLength = 512;  % ÿ�����ڵĳ���
channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��
mu_channel = 14;  % ���ڼ���ERD/ERS�ļ���channels����Ҫȷ����λ�õ�
EI_channel = 10;  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�
weight_mu = 0.6;  % ���ڼ���ERD/ERSָ���EIָ��ļ�Ȩ��

% ͨ������
ip = '172.18.22.21';
port = 8888;  % �ͺ�˷��������ӵ���������

%% ׼����ʼ�Ĵ洢���ݵ��ļ���
foldername = ['.\\', FunctionNowFilename([subject_name, '_'], '_data')]; % ָ���ļ���·��������
if ~exist(foldername, 'dir')
   mkdir(foldername);
end

%% ���������ŵ���
Trigger = 0;                                                               % ��ʼ��Trigger�����ں��������ݴ洢
AllTrial = 0;

if session_idx == 1  % ����ǵ�һ��session������Ҫ������ص����񼯺�
    Level2task(MotorClass, MajorPoportion, TrialNum, DiffLevels, foldername, subject_name);
    path = [foldername, '\\', 'Level2task', '_', subject_name, '\\', 'Online_EEGMI_session_', num2str(session_idx), '_', subject_name, '.mat'];
    ChoiceTrial = load(path,'session');
else
    path = [foldername, '\\', 'Level2task', '_', subject_name, '\\', 'Online_EEGMI_session_', num2str(session_idx), '_', subject_name, '.mat'];
    ChoiceTrial = load(path,'session');
end

ChoiceTrial = ChoiceTrial.session;
%% ��ʼʵ�飬���߲ɼ�
Timer = 0;
TrialData = [];
scores = [];  % ���ڴ洢ÿһ��trial����ķ���ֵ
scores_trial = [];  % ���ڴ洢ÿһ��trial��ƽ������ֵ
clsFlag = 0; % �����ж�ʵʱ�����Ƿ���ȷ��flag
Trials = [];
Trials = [Trials, ChoiceTrial(1,1)];  % ��ʼ��RandomTrial����һ����ֵ��ChoiceTrial���񼯺��еĵ�һ��
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
            Trigger = RandomTrial(AllTrial);  % ���Ŷ�����AO������Idle, MI1, MI2��
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
    end
    
    % ��4s��ʼȡ512��Trigger~=6��MI�Ĵ��ڣ����ݴ����ҽ��з���
    if Timer > 3 && Trials(AllTrial)> 0 && clsFlag == 0
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess(rawdata, Trials(AllTrial), sample_frequency, WindowLength, channels);
        mu_suppression = (mu_power_MI(1,mu_channel) - mu_power_(1,mu_channel))/mu_power_(1,mu_channel);  % ����miuƵ��˥�����
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index;  % ����÷�
        scores = [scores, score];  % ����÷�
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score;0;0;0;0 ];
        order = 1.0;
        resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data, foldername);  % �������ݸ����ϵ�ģ�ͣ����������
        if resultMI == Trials(AllTrial)
            clsFlag = 1;  % ʶ����ȷ����1
        else
            clsFlag = 0;
        end        
    end
    
   %% �˶�������뷴���׶Σ����/ʱ�䷶Χ��û����ԣ�,ͬʱ����ģ��
   % ����˿�ʼ���Ŷ��� 
   if clsFlag == 1 
        clsTime = Timer;  % ���Ƿ�����ȷ��ʱ��
        if Trials(AllTrial) > 0  % �˶���������
            Trigger = RandomTrial(AllTrial);  % ���Ŷ�����AO������Idle, MI1, MI2��
            mat2unity = ['0', num2str(Trigger + 3)];
            sendbuf(1,1) = hex2dec(mat2unity) ;
            sendbuf(1,2) = hex2dec('01') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % �������ݺ͸���ģ��
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score;0;0;0;0 ];
        order = 2.0;  % �������ݺ�ѵ��������
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
   end
    
    % ����˿�ʼ��Ϣ������
    if clsFlag == 0 && Timer == (MaxMITime + 2)
        clsTime = Timer;  % ���Ƿ�����ȷ��ʱ��
        if Trials(AllTrial)==2  % �˶���������
            Trigger = 2;
            sendbuf(1,1) = hex2dec('02') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % �������ݺ͸���ģ��
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score;0;0;0;0 ];
        order = 2.0;  % �������ݺ�ѵ��������
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
    end
    
   %% ��Ϣ�׶Σ�ȷ����һ������
    % ����ֻ��5s����Ϣ
    if Timer==7 && Trials(AllTrial)==0  %��ʼ��Ϣ
        Trigger = 6;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % �����㷨
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score;0;0;0;0 ];
        order = 2.0;  % �������ݺ�ѵ��������
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
        % ����ȷ����һ������
        average_score = average(scores);
        scores_trial = [scores_trial, average_score];  % �洢��ƽ���ķ���
        [Trials, ChoiceTrial] = TaskAdjust(scores_trial, ChoiceTrial, Trials, AllTrial, DiffLevels);
    end
    
    % �˶����������֮��AO������֮��������Ϣ
    if Timer == (clsTime + 5) && clsFlag == 1  %��ʼ��Ϣ
        Trigger = 6;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % ����ȷ����һ������
        average_score = average(scores);
        scores_trial = [scores_trial, average_score];  % �洢��ƽ���ķ���
        [Trials, ChoiceTrial] = TaskAdjust(scores_trial, ChoiceTrial, Trials, AllTrial, DiffLevels);
    end
    % �˶�����û����ԣ����ѽ�����֮��������Ϣ
    if clsFlag == 0 && Timer == (MaxMITime + 2 + 5)
        Trigger = 6;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % ����ȷ����һ������
        average_score = average(scores);
        scores_trial = [scores_trial, average_score];  % �洢��ƽ���ķ���
        [Trials, ChoiceTrial] = TaskAdjust(scores_trial, ChoiceTrial, Trials, AllTrial, DiffLevels);
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
        Timer = 0;  % ��ʱ����0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % ��ʾ�������
    end
    % �����֮��AO֮����Ϣ3s֮�󣬽�����Ϣ��׼����һ��
    if Timer == (clsTime + 5 + 3) && clsFlag == 1  %������Ϣ
        Timer = 0;  % ��ʱ����0
        clsFlag = 0;  % ����flag��0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % ��ʾ�������
    end
    
    % �˶�����û����ԣ�����֮����Ϣ3s֮�󣬽�����Ϣ��׼����һ��
    if clsFlag == 0 && Timer == (MaxMITime + 2 + 5 + 3)
        Timer = 0;  % ��ʱ����0
        clsFlag = 0;  % ����flag��0
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

%% �����ʼ���ɵĺ���
function Level2task(MotorClasses, MajorPoportion, TrialNum, DiffLevels, foldername, subject_name)  % MajorPoportion ÿһ��session�е���Ҫ�����ı�����TrailNum ÿһ��session�е�trial����, DiffLevels�ӵ͵��������Ѷȵľ��󣬾��������ֵԽ�߱�ʾ�Ѷ�Խ�� 
    
    foldername = [foldername, '\\', 'Level2task', '_', subject_name]; % ָ���ļ���·��������
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end
    
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
            NumMinor = round(TrialNum * MinorProportion);
            session = [session, repmat(MotorMinor, 1, NumMinor)];  % ���ʣ�µĶ���
        end    
        session = [session, repmat(0, 1, NumMinor)];  % ��Ӻ�ʣ�¶���һ�±����Ŀ��붯��
        path = [foldername, '\\', 'Online_EEGMI_session_', num2str(SessionIndex), '_', subject_name, '.mat'];
        save(path,'session');  % �洢������ݣ�����洢��
    end
    
end
%% ʵʱ������ȵĺ���
function [Trials, ChoiceTrial] = TaskAdjust(scores_trial, ChoiceTrial, Trials, AllTrial, DiffLevels)
    
    if AllTrial < 4  % ǰ4��trial�����޷��������ݲɼ������Ծ��������ѡ
        n_ = length(ChoiceTrial);
        idx = randi(n_);  % �����ѡ����ֵ
        task_ = ChoiceTrial(1,idx);
        ChoiceTrial(1,idx) = [];  % ѡ��task_��ֵ���Լ���ChoiceTrial����ȥ�����ѡ�е���ֵ
        Trials = [Trials, task_];  % ����Trials
    else
        % ������Ҫдtrial��������4�������Ҫ������ص�scores����������ж�
        delta_score = scores_trial(end-2:end) - scores_trial(end-3,end-1);  % �������ȥ3��trial�ķ����仯
        delta_score(delta_score<=0) = -1;
        delta_score(delta_score>0) = 1;  % ����delta_score����ֵ����ӳ�䣬ӳ��Ľ�������������ж�
        
        deltaSum_ = sum(delta_score);
        switch deltaSum_
            case 3
                % �����ʱ�ǲ������ߵģ���ôΪ�˷�ֹƣ�ͣ����ʵ��õ����Ѷ�
                currentTask_ = Trials(1, AllTrial);
                if currentTask_ > 0
                    diff_idx = find(DiffLevels, currentTask_);  % ȷ����ǰ���ѶȲ㼶
                else
                    diff_idx = 0;
                end
                % ���ɱ�ѡ���Ѷ�
                diff_choice = [];
                if diff_idx > 1
                    diff_choice = [diff_choice, diff_idx-1:-1:1];  % ����ѡ��һ�ȼ����Ѷ�, ���ѡ�����е��ڴ��Ѷȵ���ֵ
                    task_choice = DiffLevels(diff_choice);
                    task_choice = [task_choice, 0];  % ������Ϣ״̬
                else
                    task_choice = [task_choice, 0];  % ������Ϣ״̬
                end
                output_ = find_task_choice(task_choice, DiffLevels, 1);
                task_ = output_(1,1);
                
            case 1
                % �����ʱ�����߶��ཱུ�͵ģ���ô�������������Ѷ�
                currentTask_ = Trials(1, AllTrial);
                if currentTask_ > 0
                    diff_idx = find(DiffLevels, currentTask_);  % ȷ����ǰ���ѶȲ㼶
                else
                    diff_idx = 0;
                end
                % ���ɱ�ѡ���Ѷ�
                diff_choice = [];
                diff_choice = [diff_choice, diff_idx+1:1:length(DiffLevels)];  % ����ѡ������һ�ȼ����Ѷ�, ���ѡ�����е��ڴ��Ѷȵ���ֵ
                task_choice = DiffLevels(diff_choice);
                output_ = find_task_choice(task_choice, DiffLevels, 0);
                task_ = output_(1,1);
                
            case -1
                % �����ʱ�ǽ��Ͷ������ߵģ���ô�������������Ѷ�
                currentTask_ = Trials(1, AllTrial);
                if currentTask_ > 0
                    diff_idx = find(DiffLevels, currentTask_);  % ȷ����ǰ���ѶȲ㼶
                else
                    diff_idx = 0;
                end
                % ���ɱ�ѡ���Ѷ�
                diff_choice = [];
                diff_choice = [diff_choice, diff_idx+1:1:length(DiffLevels)];  % ����ѡ������һ�ȼ����Ѷ�, ���ѡ�����е��ڴ��Ѷȵ���ֵ
                task_choice = DiffLevels(diff_choice);
                output_ = find_task_choice(task_choice, DiffLevels, 0);
                task_ = output_(1,1);
                
            case -3
                % �����ʱ�ǲ��Ͻ��͵ģ���ôΪ�˷�ֹƣ�ͣ����ʵ��õ����Ѷ�
                currentTask_ = Trials(1, AllTrial);
                if currentTask_ > 0
                    diff_idx = find(DiffLevels, currentTask_);  % ȷ����ǰ���ѶȲ㼶
                else
                    diff_idx = 0;
                end
                % ���ɱ�ѡ���Ѷ�
                diff_choice = [];
                if diff_idx > 1
                    diff_choice = [diff_choice, diff_idx-1:-1:1];  % ����ѡ��һ�ȼ����Ѷ�, ���ѡ�����е��ڴ��Ѷȵ���ֵ
                    task_choice = DiffLevels(diff_choice);
                    task_choice = [task_choice, 0];  % ������Ϣ״̬
                else
                    task_choice = [task_choice, 0];  % ������Ϣ״̬
                end
                output_ = find_task_choice(task_choice, DiffLevels, 1);
                task_ = output_(1,1);
                
        end
        % Trials�����������
        Trials = [Trials, task_];
        % ���񼯺�ChoiceTrial����ɾ������
        index = find(ChoiceTrial == task_, 1);
        if ~isempty(index)
            ChoiceTrial(index) = [];
        end
    end
end


% ��DiffLevels��Ѱ���ض�����ĺ���
function output = find_task_choice(task_choice, DiffLevels, add_flag)
    output = [];
    for i = 1:length(task_choice)
        if ismember(task_choice(i), DiffLevels)
            output = [output, task_choice(i)];
        end
    end
    if isempty(output)  % ����Ҳ������ʵ�����ֱ������add_flagѡ����������С
        if add_flag
            output = [output, min(DiffLevels)];
        else
            output = [output, max(DiffLevels)];
        end
    end
end
