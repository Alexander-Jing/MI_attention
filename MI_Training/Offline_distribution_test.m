%% 用于检验被试mu衰减数据分布是否满足一定的正态分布
mu_suppressions_data  = load('F:\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_offline_test_20240125_203932146_data\Offline_EEGMI_Scores_Jyt_test_0125_offline_test\Offline_EEGMI_Scores_Jyt_test_0125_offline_test.mat', 'mu_suppressions');
mu_suppressions_data = mu_suppressions_data.mu_suppressions;

Triggers_data = mu_suppressions_data(2,:);
mu_suppressions_idle = mu_suppressions_data(1, Triggers_data==0);
mu_suppressions_Drinking = mu_suppressions_data(1, Triggers_data==1);
mu_suppressions_Pouring = mu_suppressions_data(1, Triggers_data==2);

data = mu_suppressions_idle;

% % Shapiro-Wilk检验
% [p,sw] = swtest(data);
% fprintf('Shapiro-Wilk检验统计量: %f\n', sw);
% fprintf('p值: %f\n', p);

% Jarque-Bera检验
[h,p,jbstat,critval] = jbtest(data);
fprintf('Jarque-Bera检验统计量: %f\n', jbstat);
fprintf('临界值: %f\n', critval);
fprintf('p值: %f\n', p);

% 如果p值小于0.05，我们通常会拒绝原假设（数据符合正态分布）

% 计算偏度
skewnessValue = skewness(data);
fprintf('偏度: %f\n', skewnessValue);

% 计算峰度
kurtosisValue = kurtosis(data) - 3; % MATLAB计算的是超额峰度，所以需要减3
fprintf('峰度: %f\n', kurtosisValue);

% 判断偏度和峰度是否接近0
if abs(skewnessValue) < 0.5 && abs(kurtosisValue) < 0.5
    fprintf('偏度和峰度都接近0，数据可能符合正态分布。\n');
else
    fprintf('偏度或峰度不接近0，数据可能不符合正态分布。\n');
end


%% 获取平均参与度分数的函数
function mean_std_scores = compute_mean_std(scores_task, scores_name)
    % 获取scores和triggers
    scores = scores_task(1,:);
    triggers = scores_task(2,:);

    % 获取所有不同的triggers
    unique_triggers = unique(triggers);

    % 初始化输出
    mean_scores = zeros(size(unique_triggers));
    std_scores = zeros(size(unique_triggers));

    % 对于每一个trigger，计算对应的score的均值
    for i = 1:length(unique_triggers)
        trigger = unique_triggers(i);
        mean_scores(i) = mean(scores(triggers == trigger));
        std_scores(i) = std(scores(triggers == trigger));
    end
    mean_std_scores = [mean_scores; std_scores];

    % 输出结果
    disp(['每一个Trigger的平均', scores_name, '分数是：']);
    for i = 1:length(unique_triggers)
        disp(['Trigger ' num2str(unique_triggers(i)) ' 的平均分数是 ' num2str(mean_scores(i))]);
        disp(['Trigger ' num2str(unique_triggers(i)) ' 的标准差是 ' num2str(std_scores(i))]);
    end
end