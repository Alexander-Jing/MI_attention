% This Script is for MI-BCI Discrete Trial-based offline training session.
% No VR feedback.
% Contains 4 types of motor imagery tasks: idle(Trigger=1),walk(Trigger=2),
% go upstairs(Trigger=3),go downstairs(Trigger=4).
% (For resting & foucusing stage of each trial, Trigger = 6)
% 4 task types * 15 trials/task type = 60 trials, where the task of each
% trials are randomly generated.

pnet('closeall');
clc;
clear;
close all;
%% 启动Unity程序，并初始化
% 程序说明：发送命令共5字节
%           Byte1：画面/动作切换
%           Byte2：控制画面是否运动
%           Byte3：画面文字显示（离线训练实验无文字提示）
%           Byte4：动作类型
%           Byte5：预留
%system('F:\CASIA\mwl_data_collection\climbstair\ClimbStair3.exe&');      % Unity动画exe文件地址
system('E:\MI_engagement\unity_test\unity_test\build_test\unity_test.exe&');
pause(3)
UnityControl = tcpip('localhost', 8881, 'NetworkRole', 'client');          % 新的端口改为8881
fopen(UnityControl);
pause(1)
sendbuf = uint8(1:5);
sendbuf(1,1) = hex2dec('01') ;
sendbuf(1,2) = hex2dec('00') ;
sendbuf(1,3) = hex2dec('00') ;
sendbuf(1,4) = hex2dec('00') ;
sendbuf(1,5) = hex2dec('00') ;
fwrite(UnityControl,sendbuf);
pause(3)

while(true)
    % loop 1：cross, MI, rest
    sendbuf(1,1) = hex2dec('02') ;
    sendbuf(1,2) = hex2dec('00') ;
    sendbuf(1,3) = hex2dec('00') ;
    sendbuf(1,4) = hex2dec('00') ;
    fwrite(UnityControl,sendbuf);       
    pause(1);
    disp('scene 02 cross');
    
    sendbuf(1,1) = hex2dec('03') ;
    sendbuf(1,2) = hex2dec('00') ;
    sendbuf(1,3) = hex2dec('00') ;
    sendbuf(1,4) = hex2dec('00') ;
    fwrite(UnityControl,sendbuf);       
    pause(3);
    disp('scene 03 MI');
    
    sendbuf(1,1) = hex2dec('04') ;
    sendbuf(1,2) = hex2dec('00') ;
    sendbuf(1,3) = hex2dec('00') ;
    sendbuf(1,4) = hex2dec('00') ;
    fwrite(UnityControl,sendbuf);       
    pause(1);
    disp('scene 04 rest');
    
     % loop 2：cross, Idle, rest
    sendbuf(1,1) = hex2dec('02') ;
    sendbuf(1,2) = hex2dec('00') ;
    sendbuf(1,3) = hex2dec('00') ;
    sendbuf(1,4) = hex2dec('00') ;
    fwrite(UnityControl,sendbuf);       
    pause(1);
    disp('scene 02 cross');
    
    sendbuf(1,1) = hex2dec('01') ;
    sendbuf(1,2) = hex2dec('00') ;
    sendbuf(1,3) = hex2dec('00') ;
    sendbuf(1,4) = hex2dec('00') ;
    fwrite(UnityControl,sendbuf);       
    pause(3);
    disp('scene 01 Idle');
    
    sendbuf(1,1) = hex2dec('04') ;
    sendbuf(1,2) = hex2dec('00') ;
    sendbuf(1,3) = hex2dec('00') ;
    sendbuf(1,4) = hex2dec('00') ;
    fwrite(UnityControl,sendbuf);       
    pause(1);
    disp('scene 04 rest');
    
end


