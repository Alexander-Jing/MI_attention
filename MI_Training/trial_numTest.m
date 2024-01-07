MotorClasses = 2;
TrialNum = 30;  % 设置采集的数量
TrialIndex = randperm(TrialNum);                                           % 根据采集的数量生成随机顺序的数组
%All_data = [];
Trigger = 0;                                                               % 初始化Trigger，用于后续的数据存储
AllTrial = 0;

randomindex = [];                                                          % 初始化trials的集合
for i= 1:(MotorClasses)
    index_i = ones(TrialNum/MotorClasses,1)*i;                             % size TrialNum/MotorClasses*1，各种任务
    randomindex = [randomindex; index_i];                                  % 各个任务整合，最终size TrialNum*1
end
              
RandomTrial = randomindex(TrialIndex);                                     % 随机生成各个Trial对应的任务

mu_test = [];
while(AllTrial < TrialNum)
    AllTrial = AllTrial + 1;
    Trigger = RandomTrial(AllTrial); 
    mu_test = [mu_test, Trigger];
    disp(['Trial ', num2str(AllTrial)]);
    disp(['Trigger', num2str(Trigger)]);
    
end
disp(size(mu_test));