%% 获取4分位数（0.25,0.5,0.75）
function [quartile_caculation, min_max_value] = Offline_Bootstrapping_quartile(scores_data, scores_name, nBootstrap)
    
    % 获取scores和triggers
    scores_ = scores_data(1,:);
    Triggers_data = scores_data(2,:);
    
    % 获取所有不同的Triggers
    unique_triggers = unique(Triggers_data);
    
    % 初始化输出
    dataQ1 = zeros(size(unique_triggers));
    dataQ2 = zeros(size(unique_triggers));
    dataQ3 = zeros(size(unique_triggers));
    data_min = zeros(size(unique_triggers));
    data_max = zeros(size(unique_triggers));
    
    if nBootstrap == 0
        for class_idx = 1:length(unique_triggers)
            % 计算分位数和最大最小数值
            trigger = unique_triggers(class_idx);
            data_ = scores_(Triggers_data == trigger);
            dataQ1(class_idx) = quantile(data_, 0.25);
            dataQ2(class_idx) = quantile(data_, 0.50);
            dataQ3(class_idx) = quantile(data_, 0.75);
            data_min(class_idx) = min(data_);
            data_max(class_idx) = max(data_);

            disp(['类别：', num2str(class_idx)]);
            disp(['指标：', scores_name]);
            fprintf('第一四分位数: %f\n', dataQ1(class_idx));
            fprintf('第二四分位数: %f\n', dataQ2(class_idx));
            fprintf('第三四分位数: %f\n', dataQ3(class_idx));
        end
        quartile_caculation = [dataQ1; dataQ2; dataQ3];
        min_max_value = [data_max; data_min];
    else
        bootstrapStdQ1 = zeros(size(unique_triggers));
        bootstrapStdQ2 = zeros(size(unique_triggers));
        bootstrapStdQ3 = zeros(size(unique_triggers));
        for class_idx = 1:length(unique_triggers)
            trigger = unique_triggers(class_idx);
            data_ = scores_(Triggers_data == trigger);
            n = length(data_); % 数据的数量
            bootstrapSampleQ1 = zeros(nBootstrap, 1); % 初始化bootstrap样本（第一四分位数）
            bootstrapSampleQ2 = zeros(nBootstrap, 1); % 初始化bootstrap样本（第二四分位数，即中位数）
            bootstrapSampleQ3 = zeros(nBootstrap, 1); % 初始化bootstrap样本（第三四分位数）
            % 生成bootstrap样本
            for Bootstrap_idx = 1:nBootstrap
                resampleIndex = randsample(n, n, true); % 有放回地随机抽取n个样本
                resample = data(resampleIndex); % 得到重抽样的数据
                bootstrapSampleQ1(Bootstrap_idx) = quantile(resample, 0.25); % 计算重抽样数据的第一四分位数
                bootstrapSampleQ2(Bootstrap_idx) = quantile(resample, 0.50); % 计算重抽样数据的第二四分位数
                bootstrapSampleQ3(Bootstrap_idx) = quantile(resample, 0.75); % 计算重抽样数据的第三四分位数
            end
            % 计算bootstrap样本的均值和标准差，作为四分位数的估计值和标准误
            dataQ1(class_idx) = mean(bootstrapSampleQ1);
            bootstrapStdQ1(class_idx) = std(bootstrapSampleQ1);
            dataQ2(class_idx) = mean(bootstrapSampleQ2);
            bootstrapStdQ2(class_idx) = std(bootstrapSampleQ2);
            dataQ3(class_idx) = mean(bootstrapSampleQ3);
            bootstrapStdQ3(class_idx) = std(bootstrapSampleQ3);
            
            % 计算分位数和最大最小数值
            disp(['类别：', num2str(class_idx)]);
            disp(['指标：', scores_name]);
            fprintf('第一四分位数的估计值: %f\n', dataQ1(class_idx));
            fprintf('第一四分位数的标准误: %f\n', bootstrapStdQ1(class_idx));
            fprintf('第二四分位数的估计值: %f\n', dataQ2(class_idx));
            fprintf('第二四分位数的标准误: %f\n', bootstrapStdQ2(class_idx));
            fprintf('第三四分位数的估计值: %f\n', dataQ3(class_idx));
            fprintf('第三四分位数的标准误: %f\n', bootstrapStdQ3(class_idx));

            data_min(class_idx) = min(data_);
            data_max(class_idx) = max(data_);
        end
        quartile_caculation = [dataQ1; dataQ2; dataQ3];
        min_max_value = [data_max; data_min];
    end
end
