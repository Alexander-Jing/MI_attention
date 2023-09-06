% %% 数据在线交互测试
% % 模拟在线产生的数据
% data_x = randn(30, 512);
% config = whos('data_x');
% data2Server = data_x;
% motor_class = 1; % 运动想象类型的编码，上传的时候记得减去1 
% config_data = [512;30;0;motor_class-1];  % 登记上传的数据的相关参数，分别是WindowLength，channels，空出来的数据（暂时置为0），运动想象类别
% time_out = 60; % 投送数据包的等待时间
% tcpipClient = tcpip('172.18.22.21', 8888,'NetworkRole','Client');
% set(tcpipClient,'OutputBufferSize',4*999*30*256*8*10);%2048*4096 67108880+64
% set(tcpipClient,'Timeout',time_out);
% tcpipClient.InputBufferSize = 8388608;%8M
% tcpipClient.ByteOrder = 'bigEndian';
% fopen(tcpipClient);
% disp("连接成功")
% disp("数据发送")
% 
% send_order = 1.0;  % 发送命令控制，用于控制服务器，命令为1是实时交互命令，命令为3是上传数据的命令
% send_data = [send_order; config_data(:); data2Server(:)];
% config_send = whos('send_data');   % whos('send_data')将返回该变量的名称、大小、字节数、类型等信息
% fwrite(tcpipClient,[config_send.bytes/2; send_data],'float32');  % 这里matlab的double是8个字节，然后这里使用的4字节的float32传输，所以config_send.bytes要除以2，表示使用4字节的float32形式传输用了多少个字节
% 
% % 接收数据
% disp("数据接收")
% recv_data = [];
% %重复多次接收
% h=waitbar(0,'正在接收数据');
% while isempty(recv_data)
%     recv_data=fread(tcpipClient);%读取第一组数据
% end
% header = convertCharsToStrings(native2unicode(recv_data,'utf-8'));
% recv_bytes = str2double(regexp(header,'(?<=(L": )).*?(?=(,|$))','match'))-2;%正则化提取数据大小
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
%     R = dic.R;
%     disp('接收到数据: ')
%     disp(R)
% catch
%     disp('WARNNING:接收不完全')
% end
% disp('连接断开')
% 
% fclose(tcpipClient);

MotorClasses = 3; 
MajorPoportion = 0.6;
TrialNum = 40;
DiffLevels = [2,1,3];  % MajorPoportion 每一个session中的主要动作的比例；TrailNum 每一个session中的trial数量, DiffLevels从低到高生成难度的矩阵，矩阵里的数值越高表示难度越高 
    
for SessionIndex = 1:MotorClasses  % 这里的SessionIndex也是主要难度对应的位置
    session = [];
    MotorMain = DiffLevels(1, SessionIndex);  % 主要成分的运动
    NumMain = round(TrialNum * MajorPoportion);  
    session = [session, repmat(MotorMain, 1, NumMain)];

    indices = find(DiffLevels==MotorMain);  % 找到MotorMain对应的index
    DiffLevels_ = DiffLevels;
    DiffLevels_(indices) = [];  % 去掉MotorMain的剩下的难度矩阵

    for i_=1:(MotorClasses - 1)
        MotorMinor = DiffLevels_(1, i_);  % 剩下的几个动作
        MinorProportion =  (1-MajorPoportion)/(MotorClasses - 1);  % 剩下动作的比重
        NumMinor = round(TrialNum * MinorProportion);
        session = [session, repmat(MotorMinor, 1, NumMinor)];  % 添加剩下的动作
    end    
    session = [session, repmat(0, 1, NumMinor)];  % 添加和剩下动作一致比例的空想动作
    %save(FunctionNowFilename(['Online_EEGMI_session_', num2str(SessionIndex)], '.mat' ),'session');  % 存储相关数据，后面存储用
    save(['Online_EEGMI_session_', num2str(SessionIndex), '_', '.mat'],'session');  % 存储相关数据，后面存储用
end
    
