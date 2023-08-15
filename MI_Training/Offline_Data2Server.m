%% 远程主机为localhost，即本地主机，要连接的目的端口为30000，作为客户机使用
client=tcpip('172.18.22.21',8888,'NetworkRole','client');
 
%% 设置接收和发送缓存区的最大容量，这里设置的是1000*1000*8，也就是一个1000*1000的double类型的数组大小
client.InputBuffersize=8000000;
client.OutputBuffersize=8000000;
 
%% 打开连接，寻找目的服务器，如果未找到，报错
fopen(client);
text = 'Fanshi';

%% 向服务器发送数据
while 1
    pause(1)
    fprintf(client,text);%发送文本数据
end