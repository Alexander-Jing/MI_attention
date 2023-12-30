%% ����ʵ��������ò��֣���������ÿһ�����Ե���������ݱ�����������޸�

% �˶����������������
subject_name = 'Jyt_online_test_offline';  % ��������
TrialNum = 30*3;  % ���òɼ�������
%TrialNum = 3*3;
MotorClasses = 3;  % �˶��������������������ã�ע�������ǰѿ���idle״̬ҲҪ�Ž�ȥ�ģ�ע�������������[0,1,2]����readme.txt����Ķ�Ӧ
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

% �������ݵ��ļ���λ������
foldername = 'Jyt_test_1230_offline_20231230_160726526_data';
windows_per_session = 149;
classes = MotorClasses;
%% ��ȡ�����������
DataX = load([foldername, '\\', 'Offline_EEGMI_Jyt_test_1230_offline', '\\', 'Offline_EEG_data_Jyt_test_1230_offline20231230_162258275.mat' ],'DataX');

%% Ԥ�������ݴ���
% ���ô���Ĳ���
send_order = 3.0;
config_data = [WindowLength, size(channels, 2), windows_per_session, classes];
%Offline_Data2Server_Send(DataX, ip, port, subject_name, config_data, send_order, foldername);
class_accuracies = Offline_Data2Server_Communicate(DataX.DataX, ip, port, subject_name, config_data, send_order, foldername);




% config = whos('data');
% time_out = 60; % 投�?�数据包的等待时�?
% tcpipClient = tcpip('172.18.22.21', 8888,'NetworkRole','Client');
% set(tcpipClient,'OutputBufferSize',67108880+64);%2048*4096
% set(tcpipClient,'Timeout',time_out);
% tcpipClient.InputBufferSize = 8388608;%8M
% tcpipClient.ByteOrder = 'bigEndian';
% fopen(tcpipClient);
% disp("连接成功")
% disp("数据发�??")
% 
% send_order = 1.0;  % 发�?�命令控制，用于控制服务�?
% send_data = [send_order; config.size(:); data(:)];
% config_send = whos('send_data');   % whos('send_data')将返回该变量的名称�?�大小�?�字节数、类型等信息
% fwrite(tcpipClient,[config_send.bytes/2;send_data],'float32');  % 这里matlab的double�?8个字节，然后这里使用�?4字节的float32传输，所以config_send.bytes要除�?2，表示使�?4字节的float32形式传输用了多少个字�?
% 
% disp("数据接收")
% recv_data = [];
% 
% %重复多次接收
% h=waitbar(0,'正在接收数据');
% while isempty(recv_data)
%     recv_data=fread(tcpipClient);%读取第一组数�?
% end
% header = convertCharsToStrings(native2unicode(recv_data,'utf-8'));
% recv_bytes = str2double(regexp(header,'(?<=(L": )).*?(?=(,|$))','match'))-2;%正则化提取数据大�?
% while length(recv_data)<recv_bytes
%     if recv_data(end)==125
%         break
%     end
%     waitbar(length(recv_data)/recv_bytes)
%     recv_package = [];
%     while isempty(recv_package)
%         try
%             recv_package=fread(tcpipClient);
%         catch
%             continue
%         end
%     end
%     recv_data = vertcat(recv_data,recv_package);
% end
% close(h)
% chararray = native2unicode(recv_data,'utf-8');
% str = convertCharsToStrings(chararray);  % 接收到的数据，为字典格式
% try
%     dic = jsondecode(str);%将json形式的字典数据里面的矩阵数据提取
%     U = dic.U;
%     S = dic.S;
%     V = dic.V;
%     re = U*diag(S)*V;
% catch
%     disp('WARNNING:接收不完�?')
% end
% disp('连接断开')
% fclose(tcpipClient);
