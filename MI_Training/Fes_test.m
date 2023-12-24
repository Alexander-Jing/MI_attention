% for fes testing

system('E:\20220831_lty\fes\x64\Debug\fes.exe&'); 
pause(1);
StimControl = tcpip('localhost', 8888, 'NetworkRole', 'client','Timeout',1000);
StimControl.InputBuffersize = 1000;
StimControl.OutputBuffersize = 1000;

fopen(StimControl);
% StimCommand = uint8(zeros(1,6));
% StimCommand(1,1) = 0; % 0 start 100 stop
% StimCommand(1,2) = 8; % amplitude
% StimCommand(1,3) = 3; % t_up
% StimCommand(1,4) = 14; % t_flat
% StimCommand(1,5) = 2; % t_down
% StimCommand(1,6) = 3; % 1 left calf 2 left thigh 3 right thigh
% fwrite(StimControl,StimCommand);%´Ì¼¤¿ªÊ¼

tStim = [3,14,2]; % [t_up,t_flat,t_down] * 100ms
StimCommand_1 = uint8([0,11,tStim,1]); % left calf
StimCommand_2 = uint8([0,7,tStim,2]); % left thigh
StimCommand_3 = uint8([0,9,tStim,3]); % right thigh 


StimCommand = StimCommand_3;
fwrite(StimControl,StimCommand);
pause(3);
StimCommand(1,1) = 100;
fwrite(StimControl,StimCommand);

system('taskkill /F /IM fes.exe');
close all;

