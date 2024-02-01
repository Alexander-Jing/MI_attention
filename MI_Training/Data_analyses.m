%% 被试名称和实验的文件夹
root_path = 'F:\CASIA\MI_engagement\MI_attention\MI_Training';  % 根目录用于存储数据和分析
subject_name_online = 'Jyt_test_0131_online'; %'Jyt_test_0101_1_online';% 'Jyt_test_0101_online'; %  % 被试姓名
sub_online_collection_folder = 'Jyt_test_0131_online_20240131_210821243_data'; % 'Jyt_test_0101_1_online_20240101_200123314_data';  %'Jyt_test_0101_online_20240101_175129548_data'; %  % 

subject_name_offline =  'Jyt_test_0131_offline';  % 离线收集数据时候的被试名称
sub_offline_collection_folder = 'Jyt_test_0131_offline_20240131_204044614_data';  % 被试的离线采集数据

subject_name_comparison = 'Jyt_test_0131_comparison';
sub_comparison_collection_folder = 'Jyt_test_0131_comparison_20240131_194732925_data';

channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15, 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道,
mu_channels = struct('C3',24, 'C4',22);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % 用于计算EI指标的几个channels，需要确定下位置的


%% 读取各种数据，用于后面的显示和显著性分析
% 读取和计算在线数据，用于指标分析
folder_path = fullfile(sub_online_collection_folder, ['Online_Engagements_', subject_name_online]);
% [sub_online_collection_folder, '/', 'Online_Engagements_', subject_name_online]; % 请将'./your_folder'替换为您的文件夹的相对路径
[mu_suppresions, EI_index_scores, resultsMI_trials] = mu_EI_MIresult_caculation(folder_path, mu_channels, EI_channels);  % 提取相关指标

% 读取和计算后续的在线/离线和对比实验的数据，并且计算出相关的一些指标
% 读取离线的mu衰减变化
mu_suppressions_offline = load(fullfile(root_path, sub_offline_collection_folder, ['Offline_EEGMI_Scores_', subject_name_offline], ['Offline_EEGMI_Scores_', subject_name_offline,'.mat']), 'mu_suppressions');

% 读取在线的轨迹数据
Online_traj_path = fullfile(root_path, sub_online_collection_folder, ['Online_EEGMI_trajectory_', subject_name_online]);
Online_traj_files = dir(fullfile(Online_traj_path, '*.mat'));
Online_traj_file = Online_traj_files(1).name;
Online_EEGMI_trajectory = load(fullfile(Online_traj_path, Online_traj_file));
traj = Online_EEGMI_trajectory.traj;
MI_MUSup_thres = Online_EEGMI_trajectory.MI_MUSup_thres;
MI_MUSup_thre_weights = Online_EEGMI_trajectory.MI_MUSup_thre_weights;

% 读取对比实验的数据
scores_compare = load(fullfile(root_path, sub_comparison_collection_folder,['Offline_EEGMI_Scores_', subject_name_comparison], ['Offline_EEGMI_Scores_', subject_name_comparison, '.mat']));
mu_suppressions_compare = scores_compare.mu_suppressions_trialmean;
EI_index_scores_compare = scores_compare.EI_index_scores_trialmean;

%% 读取其余在线/离线对比实验中的数据，并且计算出一些相关的指标（备用代码，平时隐藏）
%mu_suppressions_offline = load('F:\CASIA\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_offline_test_20240125_203932146_data\Offline_EEGMI_Scores_Jyt_test_0125_offline_test\Offline_EEGMI_Scores_Jyt_test_0125_offline_test.mat', 'mu_suppressions');
%mu_suppressions_offline = load('F:\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_offline_test_20240125_203932146_data\Offline_EEGMI_Scores_Jyt_test_0125_offline_test\Offline_EEGMI_Scores_Jyt_test_0125_offline_test.mat', 'mu_suppressions');

%traj = load('F:\CASIA\MI_engagement\MI_attention\MI_Training\Jyt_test_0101_1_online_20240101_200123314_data\Online_EEGMI_trajectory_Jyt_test_0101_1_online\Online_EEGMI_trajectory_1_Jyt_test_0101_1_online20240101_202353792.mat','traj');
%traj = load('F:\CASIA\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_online_test_20240125_220854676_data\Online_EEGMI_trajectory_Jyt_test_0125_online_test\Online_EEGMI_trajectory_1_Jyt_test_0125_online_test20240125_222645598.mat', 'traj');
%traj = load('F:\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_online_test_20240125_220854676_data\Online_EEGMI_trajectory_Jyt_test_0125_online_test\Online_EEGMI_trajectory_1_Jyt_test_0125_online_test20240125_222645598.mat', 'traj');

%MI_MUSup_thres = load('F:\CASIA\MI_engagement\MI_attention\MI_Training\Jyt_test_0101_1_online_20240101_200123314_data\Online_EEGMI_trajectory_Jyt_test_0101_1_online\Online_EEGMI_trajectory_1_Jyt_test_0101_1_online20240101_202353792.mat', 'MI_MUSup_thres');
%MI_MUSup_thres = load('F:\CASIA\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_online_test_20240125_220854676_data\Online_EEGMI_trajectory_Jyt_test_0125_online_test\Online_EEGMI_trajectory_1_Jyt_test_0125_online_test20240125_222645598.mat', 'MI_MUSup_thres');
%MI_MUSup_thres = load('F:\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_online_test_20240125_220854676_data\Online_EEGMI_trajectory_Jyt_test_0125_online_test\Online_EEGMI_trajectory_1_Jyt_test_0125_online_test20240125_222645598.mat', 'MI_MUSup_thres');

%MI_MUSup_thre_weights = load('F:\CASIA\MI_engagement\MI_attention\MI_Training\Jyt_test_0101_1_online_20240101_200123314_data\Online_EEGMI_trajectory_Jyt_test_0101_1_online\Online_EEGMI_trajectory_1_Jyt_test_0101_1_online20240101_202353792.mat', 'MI_MUSup_thre_weights');
%MI_MUSup_thre_weights = load('F:\CASIA\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_online_test_20240125_220854676_data\Online_EEGMI_trajectory_Jyt_test_0125_online_test\Online_EEGMI_trajectory_1_Jyt_test_0125_online_test20240125_222645598.mat', 'MI_MUSup_thre_weights');
%MI_MUSup_thre_weights = load('F:\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_online_test_20240125_220854676_data\Online_EEGMI_trajectory_Jyt_test_0125_online_test\Online_EEGMI_trajectory_1_Jyt_test_0125_online_test20240125_222645598.mat', 'MI_MUSup_thre_weights');

%mu_suppressions_compare = load('F:\CASIA\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_comparison_test_20240125_215803328_data\Offline_EEGMI_Scores_Jyt_test_0125_comparison_test\Offline_EEGMI_Scores_Jyt_test_0125_comparison_test.mat', 'mu_suppressions_trialmean');
%EI_index_scores_compare = load('F:\CASIA\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_comparison_test_20240125_215803328_data\Offline_EEGMI_Scores_Jyt_test_0125_comparison_test\Offline_EEGMI_Scores_Jyt_test_0125_comparison_test.mat', 'EI_index_scores_trialmean');

%mu_suppressions_compare = load('F:\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_comparison_test_20240125_215803328_data\Offline_EEGMI_Scores_Jyt_test_0125_comparison_test\Offline_EEGMI_Scores_Jyt_test_0125_comparison_test.mat', 'mu_suppressions_trialmean');
%EI_index_scores_compare = load('F:\MI_engagement\MI_attention\MI_Training\Jyt_test_0125_comparison_test_20240125_215803328_data\Offline_EEGMI_Scores_Jyt_test_0125_comparison_test\Offline_EEGMI_Scores_Jyt_test_0125_comparison_test.mat', 'EI_index_scores_trialmean');

%% 提取数据，并且计算均值和标准差
% 提取第一行的数据
MI_MUSup_thres_row1 = MI_MUSup_thres;
MI_MUSup_thre_weights_row1 = MI_MUSup_thre_weights(1,:);

% 进行除法计算,得到原来的实际的轨迹
MI_MUSUP_trajs = MI_MUSup_thre_weights_row1 ./ MI_MUSup_thres_row1;


% 计算mu_suppresions和EI_index_scores的均值和标准差
mu_suppresions_mean = mean(mu_suppresions(1,:));
mu_suppresions_std = std(mu_suppresions(1,:));
EI_index_scores_mean = mean(EI_index_scores(1,:));
EI_index_scores_std = std(EI_index_scores(1,:));

% 显示均值和标准差
fprintf('mu_suppresions: mean = %.2f, std = %.2f\n', mu_suppresions_mean, mu_suppresions_std);
fprintf('EI_index_scores: mean = %.2f, std = %.2f\n', EI_index_scores_mean, EI_index_scores_std);


%% 显示相关数值，分析显著性
% 绘制mu_suppresions和EI_index_scores的折线图
figure;
plot(mu_suppresions(1,:), 'LineWidth', 2);
hold on;
plot(mu_suppressions_compare(1,:), 'LineWidth', 2);
hold off;
legend('mu suppresions online', 'mu suppresions compare');
xlabel('Index');
ylabel('Value');
title('Line plot of mu suppresions');
grid on;

figure;
plot(EI_index_scores(1,:), 'LineWidth', 2);
hold on;
plot(EI_index_scores_compare(1,:), 'LineWidth', 2);
hold off;
legend('EI online', 'EI compare');
xlabel('Index');
ylabel('Value');
title('Line plot of EI');
grid on;

figure;
resultsTrigger = resultsMI_trials(2,:);
plot(mu_suppresions(1,:).* resultsMI_trials(1,:), 'LineWidth', 2);  %.* resultsMI_trials(1,:)
hold on;
plot(MI_MUSup_thres_row1(1,:), 'LineWidth', 2);
hold on;
plot(resultsMI_trials(1,:), 'LineWidth', 2);
hold off;
legend('mu sup online', 'mu sup thre', 'resultsMI');
xlabel('Index');
ylabel('Value');
title('Line plot of thresholds');
grid on;

figure;
resultsTrigger = resultsMI_trials(2,:);
plot(mu_suppresions(1,resultsTrigger==1).* resultsMI_trials(1,resultsTrigger==1), 'LineWidth', 2);  %.* resultsMI_trials(1,:)
hold on;
plot(MI_MUSup_thres_row1(1,resultsTrigger==1), 'LineWidth', 2);
hold on;
plot(resultsMI_trials(1,resultsTrigger==1), 'LineWidth', 2);
hold off;
legend('mu sup online', 'mu sup thre', 'resultsMI');
xlabel('Index');
ylabel('Value');
title('Line plot of thresholds task 1');
grid on;

figure;
plot(mu_suppresions(1,resultsTrigger==2).* resultsMI_trials(1,resultsTrigger==2), 'LineWidth', 2);  %.* resultsMI_trials(1,:)
hold on;
plot(MI_MUSup_thres_row1(1,resultsTrigger==2), 'LineWidth', 2);
hold on;
plot(resultsMI_trials(1,resultsTrigger==2), 'LineWidth', 2);
hold off;
legend('mu sup online', 'mu sup thre', 'resultsMI');
xlabel('Index');
ylabel('Value');
title('Line plot of thresholds task 2');
grid on;

figure;
resultsTrigger = resultsMI_trials(2,:);
plot(resultsMI_trials(1,resultsTrigger==1), 'LineWidth', 2);
hold on;
plot(resultsMI_trials(1,resultsTrigger==2), 'LineWidth', 2);
hold off;
legend('results MI 1', 'results MI 2');
xlabel('Index');
ylabel('Value');
title('Line plot of results of each MI');
grid on;

disp('methods on mu_suppresions');
[p_ttest, p_ranksum] = significance_analysis(mu_suppresions, mu_suppressions_compare);
significance_show(p_ttest,p_ranksum);
disp('methods on EI');
[p_ttest, p_ranksum] = significance_analysis(EI_index_scores, EI_index_scores_compare);
significance_show(p_ttest,p_ranksum);
disp('methods on mu_suppresions on triggers');
[p_ttest, p_ranksum] = significance_analysis_trigger(mu_suppresions, mu_suppressions_compare);
significance_show(p_ttest,p_ranksum);
disp('methods on EI_index_scores on triggers');
[p_ttest, p_ranksum] = significance_analysis_trigger(EI_index_scores, EI_index_scores_compare);
significance_show(p_ttest,p_ranksum);

disp('method 1 on correlations on the mu_suppresions and EI_index_scores');
display_correlation(mu_suppresions, EI_index_scores);
display_correlation_trigger(mu_suppresions, EI_index_scores);

disp('method 1 on correlations on the resultsMI_trials and EI_index_scores');
display_correlation(mu_suppresions(1,:).*resultsMI_trials(1,:), EI_index_scores);
display_correlation_trigger(resultsMI_trials, EI_index_scores);

%disp('method 2 on correlations on the mu_suppresions and EI_index_scores');
%display_correlation(mu_suppressions_compare.mu_suppressions_trialmean, EI_index_scores_compare.EI_index_scores_trialmean);
%p_anova = anova_analysis(mu_suppresions, mu_suppressions_offline.mu_suppressions);



%mean_std_muSup_online = compute_mean_std(mu_suppresions, 'mu_suppressions');  
%mean_std_EI_score_online = compute_mean_std(EI_index_scores, 'EI_index_scores');

%% 读取在线的文件中的每一个数据
function [mu_suppresions, EI_index_scores, resultsMI_trials] = mu_EI_MIresult_caculation(folder_path, mu_channels, EI_channels)
    % 切换到指定的文件夹
    cd(folder_path);
    
    % 获取文件夹中的所有.mat文件
    files = dir('*.mat');
    
    % 提取出文件名中的c的值，并转换为数字
    c_values = cellfun(@(x) str2double(regexp(x, 'trial_(\d+)', 'tokens', 'once')), {files.name});
    
    % 根据c的值对文件进行排序
    [~, index] = sort(c_values);
    files = files(index);
    
    % 初始化mu_suppresions和EI_index_scores
    mu_suppresions = [];
    EI_index_scores = [];
    resultsMI_trials = [];
    
    % 遍历每个文件
    for i = 1:length(files)
        % 加载.mat文件
        data = load(files(i).name);
        
        % 提取mu_powers和EI_indices
        mu_powers = data.mu_powers;
        EI_indices = data.EI_indices;
        % 提取分类概率
        resultsMI = data.resultsMI;
        
        % 提取mu_power_和mu_power
        mu_power_ = mu_powers(:,1);
        mu_powers = mu_powers(:,2:end);
        
        resultsMI = resultsMI(2:end,:);
        
        % 计算mu_suppresion
        mu_suppresion = zeros(1, size(mu_powers, 2));
        Trigger = mu_powers(33,1);
        for j = 1:size(mu_powers, 2)
            mu_power = mu_powers(:,j);
            mu_suppresion(j) = MI_MuSuperesion(mu_power_, mu_power, mu_channels);
        end
        
        % 计算mu_suppresion的均值并保存
        %mu_suppresions = [mu_suppresions, [mu_suppresion; repmat(Trigger,1,size(mu_powers, 2))]];
        mu_suppresions = [mu_suppresions, [mean(mu_suppresion); Trigger]];
        
        % 计算EI_index_score
        EI_index_score = zeros(1, size(EI_indices, 2));
        for j = 1:size(EI_indices, 2)
            EI_index = EI_indices(:,j);
            EI_index_score(j) = EI_index_Caculation(EI_index, EI_channels);
        end
        
        % 计算EI_index_score的均值并保存
        %EI_index_scores = [EI_index_scores, [EI_index_score; repmat(Trigger,1,size(mu_powers, 2))]];
        EI_index_scores = [EI_index_scores, [mean(EI_index_score); Trigger]];
        
        % 计算分类概率在这一个trial里面的均值
        resultsMI_trials = [resultsMI_trials, [mean(resultsMI(1,:)); Trigger]];
    end
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

%% 计算相关mu频带衰减指标
function mu_suppresion = MI_MuSuperesion(mu_power_, mu_power, mu_channels)
    ERD_C3 = (mu_power(mu_channels.C3, 1) - mu_power_(mu_channels.C3, 1)); 
    %ERD_C4 = (mu_power(mu_channels.C4, 1) - mu_power_(mu_channels.C4, 1));  % 计算两个脑电位置的相关的指标 
    mu_suppresion = - ERD_C3;  % 归一化到[0,1]的区间里面
end
    
%% 计算相关的EI指标的函数
function EI_index_score = EI_index_Caculation(EI_index, EI_channels)
    channels_ = [EI_channels.Fp1,EI_channels.Fp2, EI_channels.F7, EI_channels.F3, EI_channels.Fz, EI_channels.F4, EI_channels.F8'];
    EI_index_score = mean(EI_index(channels_, 1));

end

%% 分析显著性的函数
function [p_ttest, p_ranksum] = significance_analysis_trigger(mu_suppresions1, mu_suppresions2)
    % 获取类别的唯一值
    categories = unique(mu_suppresions1(2,:));

    % 初始化p值
    p_ttest = zeros(1, length(categories));
    p_ranksum = zeros(1, length(categories));

    % 对每个类别进行显著性分析
    for i = 1:length(categories)
        % 获取当前类别
        category = categories(i);
        
        % 提取出当前类别的数据
        data1 = mu_suppresions1(1, mu_suppresions1(2,:) == category);
        data2 = mu_suppresions2(1, mu_suppresions2(2,:) == category);
        
        % 进行t检验
        [~,p_ttest(i)] = ttest2(data1, data2);
        
        % 进行Wilcoxon秩和检验
        p_ranksum(i) = ranksum(data1, data2);
    end
end

function [p_ttest, p_ranksum] = significance_analysis(mu_suppresions1, mu_suppresions2)
    
    % 初始化p值
    p_ttest = zeros(1, 1);
    p_ranksum = zeros(1, 1);

    % 提取出当前类别的数据
    data1 = mu_suppresions1(1, :);
    data2 = mu_suppresions2(1, :);
        
    % 进行t检验
    [~,p_ttest(1)] = ttest2(data1, data2);

    % 进行Wilcoxon秩和检验
    p_ranksum(1) = ranksum(data1, data2);
    
end

function [p_anova] = anova_analysis(mu_suppresions1, mu_suppresions2)
    % 获取类别的唯一值
    categories = unique([mu_suppresions1(2,:), mu_suppresions2(2,:)]);
    %categories = [2];
    % 初始化数据
    data = [];
    group = [];

    % 对每个类别进行处理
    for i = 1:length(categories)
        % 获取当前类别
        category = categories(i);
        
        % 提取出当前类别的数据
        data1 = mu_suppresions1(1, mu_suppresions1(2,:) == category);
        data2 = mu_suppresions2(1, mu_suppresions2(2,:) == category);
        
        % 将数据添加到data数组中
        data = [data, data1, data2];
        
        % 创建一个组标签数组
        group = [group, repmat({sprintf('Method1_Category%d', category)}, 1, length(data1)), ...
                         repmat({sprintf('Method2_Category%d', category)}, 1, length(data2))];
    end
    
    % 进行方差分析
    p_anova = anova1(data, group, 'off'); % 'off'表示不显示结果图表
end
% 显示结果并报告显著性
function significance_show(p_ttest,p_ranksum)
    for i = 1:length(p_ttest)
        fprintf('Category %d: p_ttest = %.4f, p_ranksum = %.4f\n', i, p_ttest(i), p_ranksum(i));
        if p_ttest(i) < 0.05
            fprintf('对于t检验，类别%d的差异是显著的。\n', i);
        else
            fprintf('对于t检验，类别%d的差异不是显著的。\n', i);
        end
        if p_ranksum(i) < 0.05
            fprintf('对于Wilcoxon秩和检验，类别%d的差异是显著的。\n', i);
        else
            fprintf('对于Wilcoxon秩和检验，类别%d的差异不是显著的。\n', i);
        end
    end
end
%% 分析相关性的函数
function [correlation, p_value] = display_correlation(data1, data2)
    % 计算相关系数和p值
    [R, P] = corrcoef(data1(1,:), data2(1,:));

    % 提取相关系数和p值
    correlation = R(1, 2);
    p_value = P(1, 2);

    % 显示相关系数和p值
    fprintf('The correlation coefficient (r) between the two datasets is: %.4f\n', correlation);
    fprintf('The p-value for this correlation is: %.4f\n', p_value);
end

function [R, P] = display_correlation_trigger(mu_suppresions1, mu_suppresions2)
    % 获取类别的唯一值
    categories = unique(mu_suppresions1(2,:));

    % 初始化p值
    R = zeros(1, length(categories));
    P = zeros(1, length(categories));

    % 对每个类别进行显著性分析
    for i = 1:length(categories)
        % 获取当前类别
        category = categories(i);
        disp(['category: ', num2str(category)]);
        % 提取出当前类别的数据
        data1 = mu_suppresions1(1, mu_suppresions1(2,:) == category);
        data2 = mu_suppresions2(1, mu_suppresions2(2,:) == category);
        
        % 进行相关性检验分析
        [R(i), P(i)] = display_correlation(data1, data2);
    end
end