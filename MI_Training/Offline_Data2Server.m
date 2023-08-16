close all;clear;clc;
data = double(rand(2048,2048));
config = whos('data');
time_out = 60; % 投送数据包的等待时间
tcpipClient = tcpip('172.18.22.21', 8888,'NetworkRole','Client');
set(tcpipClient,'OutputBufferSize',67108880+64);%2048*4096
set(tcpipClient,'Timeout',time_out);
tcpipClient.InputBufferSize = 8388608;%8M
tcpipClient.ByteOrder = 'bigEndian';
fopen(tcpipClient);
disp("连接成功")
disp("数据发送")

send_data = [config.size(:);data(:)];
config_send = whos('send_data');   % whos('send_data')将返回该变量的名称、大小、字节数、类型等信息
fwrite(tcpipClient,[config_send.bytes/2;send_data],'float32');  % 这里matlab的double是8个字节，然后这里使用的4字节的float32传输，所以config_send.bytes要除以2，表示使用4字节的float32形式传输用了多少个字节
disp("数据接收")
recv_data = [];

%重复多次接收
h=waitbar(0,'正在接收数据');
while isempty(recv_data)
    recv_data=fread(tcpipClient);%读取第一组数据
end
header = convertCharsToStrings(native2unicode(recv_data,'utf-8'));
recv_bytes = str2double(regexp(header,'(?<=(L": )).*?(?=(,|$))','match'))-2;%正则化提取数据大小
while length(recv_data)<recv_bytes
    if recv_data(end)==125
        break
    end
    waitbar(length(recv_data)/recv_bytes)
    recv_package = [];
    while isempty(recv_package)
        try
            recv_package=fread(tcpipClient);
        catch
            continue
        end
    end
    recv_data = vertcat(recv_data,recv_package);
end
close(h)
chararray = native2unicode(recv_data,'utf-8');
str = convertCharsToStrings(chararray);
try
    U = dic.U;
    S = dic.S;
    V = dic.V;
    re = U*diag(S)*V;
catch
    disp('WARNNING:接收不完全')
end
disp('连接断开')
fclose(tcpipClient);
