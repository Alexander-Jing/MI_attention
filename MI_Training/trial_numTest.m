MotorClasses = 2;
TrialNum = 30;  % ���òɼ�������
TrialIndex = randperm(TrialNum);                                           % ���ݲɼ��������������˳�������
%All_data = [];
Trigger = 0;                                                               % ��ʼ��Trigger�����ں��������ݴ洢
AllTrial = 0;

randomindex = [];                                                          % ��ʼ��trials�ļ���
for i= 1:(MotorClasses)
    index_i = ones(TrialNum/MotorClasses,1)*i;                             % size TrialNum/MotorClasses*1����������
    randomindex = [randomindex; index_i];                                  % �����������ϣ�����size TrialNum*1
end
              
RandomTrial = randomindex(TrialIndex);                                     % ������ɸ���Trial��Ӧ������

mu_test = [];
while(AllTrial < TrialNum)
    AllTrial = AllTrial + 1;
    Trigger = RandomTrial(AllTrial); 
    mu_test = [mu_test, Trigger];
    disp(['Trial ', num2str(AllTrial)]);
    disp(['Trigger', num2str(Trigger)]);
    
end
disp(size(mu_test));