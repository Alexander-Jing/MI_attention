%% 用于检验被试mu衰减数据分布是否满足一定的正态分布
mu_suppressions_data  = load('F:\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_offline_test_20240125_203932146_data\Offline_EEGMI_Scores_Jyt_test_0125_offline_test\Offline_EEGMI_Scores_Jyt_test_0125_offline_test.mat', 'mu_suppressions');
mu_suppressions_data = mu_suppressions_data.mu_suppressions;

Triggers_data = mu_suppressions_data(2,:);
mu_suppressions_idle = mu_suppressions_data(1, Triggers_data==0)*2 - 1;
mu_suppressions_Drinking = mu_suppressions_data(1, Triggers_data==1)*2 - 1;
mu_suppressions_Pouring = mu_suppressions_data(1, Triggers_data==2)*2 - 1;

data = mu_suppressions_Pouring;

dataQ1 = quantile(data, 0.25);
dataQ2 = quantile(data, 0.50);
dataQ3 = quantile(data, 0.75);
fprintf('第一四分位数: %f\n', dataQ1);
fprintf('第二四分位数: %f\n', dataQ2);
fprintf('第三四分位数: %f\n', dataQ3);



% 假设你的数据存储在名为data的向量中

% 初始化
n = length(data); % 数据的数量
nBootstrap = 1000; % bootstrap样本的数量
bootstrapSampleQ1 = zeros(nBootstrap, 1); % 初始化bootstrap样本（第一四分位数）
bootstrapSampleQ2 = zeros(nBootstrap, 1); % 初始化bootstrap样本（第二四分位数，即中位数）
bootstrapSampleQ3 = zeros(nBootstrap, 1); % 初始化bootstrap样本（第三四分位数）

% 生成bootstrap样本
for i = 1:nBootstrap
    resampleIndex = randsample(n, n, true); % 有放回地随机抽取n个样本
    resample = data(resampleIndex); % 得到重抽样的数据
    bootstrapSampleQ1(i) = quantile(resample, 0.25); % 计算重抽样数据的第一四分位数
    bootstrapSampleQ2(i) = quantile(resample, 0.50); % 计算重抽样数据的第二四分位数
    bootstrapSampleQ3(i) = quantile(resample, 0.75); % 计算重抽样数据的第三四分位数
end

% 计算bootstrap样本的均值和标准差，作为四分位数的估计值和标准误
bootstrapMeanQ1 = mean(bootstrapSampleQ1);
bootstrapStdQ1 = std(bootstrapSampleQ1);
bootstrapMeanQ2 = mean(bootstrapSampleQ2);
bootstrapStdQ2 = std(bootstrapSampleQ2);
bootstrapMeanQ3 = mean(bootstrapSampleQ3);
bootstrapStdQ3 = std(bootstrapSampleQ3);

fprintf('第一四分位数的估计值: %f\n', bootstrapMeanQ1);
fprintf('第一四分位数的标准误: %f\n', bootstrapStdQ1);
fprintf('第二四分位数的估计值: %f\n', bootstrapMeanQ2);
fprintf('第二四分位数的标准误: %f\n', bootstrapStdQ2);
fprintf('第三四分位数的估计值: %f\n', bootstrapMeanQ3);
fprintf('第三四分位数的标准误: %f\n', bootstrapStdQ3);


