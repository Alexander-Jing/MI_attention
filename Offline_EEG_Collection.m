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
sendbuf(1,1) = hex2dec('01') ;
sendbuf(1,2) = hex2dec('00') ;
sendbuf(1,3) = hex2dec('00') ;
sendbuf(1,4) = hex2dec('00') ;
sendbuf(1,5) = hex2dec('00') ;
fwrite(UnityControl,sendbuf);
pause(3)

while(true)
    % loop 1��cross, MI, rest
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
    
     % loop 2��cross, Idle, rest
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


