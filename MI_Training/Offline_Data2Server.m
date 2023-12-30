%% 在线实验参数设置部分，用于设置每一个被试的情况，依据被试情况进行修改

% 运动想象基本参数设置
subject_name = 'Jyt_online_test_offline';  % 被试姓名
TrialNum = 30*3;  % 设置采集的数量
%TrialNum = 3*3;
MotorClasses = 3;  % 运动想象的种类的数量的设置，注意这里是把空想idle状态也要放进去的，注意这里的任务是[0,1,2]，和readme.txt里面的对应
% 当前设置的任务
% Idle 0   -> SceneIdle 
% MI1 1   -> SceneMI_Drinking 
% MI2 2   -> Scene_Milk 
% 由此设置任务用的字典
task_keys = {0, 1, 2};
task_values = {'SceneIdle', 'SceneMI_Drinking', 'Scene_Milk'};
task_dict = containers.Map(task_keys, task_values);

% 脑电设备的数据采集
sample_frequency = 256; 
WindowLength = 512;  % 每个窗口的长度
channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道,
mu_channels = struct('C3',24, 'C4',22);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % 用于计算EI指标的几个channels，需要确定下位置的
weight_mu = 0.6;  % 用于计算ERD/ERS指标和EI指标的加权和

% 通信设置
ip = '172.18.22.21';
port = 8888;  % 和后端服务器连接的两个参数

% 传输数据的文件夹位置设置
foldername = 'Jyt_test_1230_offline_20231230_160726526_data';
windows_per_session = 149;
classes = MotorClasses;
%% 读取待传输的数据
DataX = load([foldername, '\\', 'Offline_EEGMI_Jyt_test_1230_offline', '\\', 'Offline_EEG_data_Jyt_test_1230_offline20231230_162258275.mat' ],'DataX');

%% 预处理数据传输
% 设置传输的参数
send_order = 3.0;
config_data = [WindowLength, size(channels, 2), windows_per_session, classes];
%Offline_Data2Server_Send(DataX, ip, port, subject_name, config_data, send_order, foldername);
class_accuracies = Offline_Data2Server_Communicate(DataX.DataX, ip, port, subject_name, config_data, send_order, foldername);




% config = whos('data');
% time_out = 60; % 鎶曢?佹暟鎹寘鐨勭瓑寰呮椂闂?
% tcpipClient = tcpip('172.18.22.21', 8888,'NetworkRole','Client');
% set(tcpipClient,'OutputBufferSize',67108880+64);%2048*4096
% set(tcpipClient,'Timeout',time_out);
% tcpipClient.InputBufferSize = 8388608;%8M
% tcpipClient.ByteOrder = 'bigEndian';
% fopen(tcpipClient);
% disp("杩炴帴鎴愬姛")
% disp("鏁版嵁鍙戦??")
% 
% send_order = 1.0;  % 鍙戦?佸懡浠ゆ帶鍒讹紝鐢ㄤ簬鎺у埗鏈嶅姟鍣?
% send_data = [send_order; config.size(:); data(:)];
% config_send = whos('send_data');   % whos('send_data')灏嗚繑鍥炶鍙橀噺鐨勫悕绉般?佸ぇ灏忋?佸瓧鑺傛暟銆佺被鍨嬬瓑淇℃伅
% fwrite(tcpipClient,[config_send.bytes/2;send_data],'float32');  % 杩欓噷matlab鐨刣ouble鏄?8涓瓧鑺傦紝鐒跺悗杩欓噷浣跨敤鐨?4瀛楄妭鐨刦loat32浼犺緭锛屾墍浠onfig_send.bytes瑕侀櫎浠?2锛岃〃绀轰娇鐢?4瀛楄妭鐨刦loat32褰㈠紡浼犺緭鐢ㄤ簡澶氬皯涓瓧鑺?
% 
% disp("鏁版嵁鎺ユ敹")
% recv_data = [];
% 
% %閲嶅澶氭鎺ユ敹
% h=waitbar(0,'姝ｅ湪鎺ユ敹鏁版嵁');
% while isempty(recv_data)
%     recv_data=fread(tcpipClient);%璇诲彇绗竴缁勬暟鎹?
% end
% header = convertCharsToStrings(native2unicode(recv_data,'utf-8'));
% recv_bytes = str2double(regexp(header,'(?<=(L": )).*?(?=(,|$))','match'))-2;%姝ｅ垯鍖栨彁鍙栨暟鎹ぇ灏?
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
% str = convertCharsToStrings(chararray);  % 鎺ユ敹鍒扮殑鏁版嵁锛屼负瀛楀吀鏍煎紡
% try
%     dic = jsondecode(str);%灏唈son褰㈠紡鐨勫瓧鍏告暟鎹噷闈㈢殑鐭╅樀鏁版嵁鎻愬彇
%     U = dic.U;
%     S = dic.S;
%     V = dic.V;
%     re = U*diag(S)*V;
% catch
%     disp('WARNNING:鎺ユ敹涓嶅畬鍏?')
% end
% disp('杩炴帴鏂紑')
% fclose(tcpipClient);
