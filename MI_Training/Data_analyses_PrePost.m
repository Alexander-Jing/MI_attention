%% 被试名称和实验的文件夹
root_path = 'F:\CASIA\MI_engagement\MI_attention\MI_Training';  % 根目录用于存储数据和分析
subject_name_post = 'Jyt_test_0310_post_control'; %'Jyt_test_0101_1_online';% 'Jyt_test_0101_online'; %  % 被试姓名
sub_post_collection_folder = 'Jyt_test_0310_post_control_20240310_212613989_data';

subject_name_pre = 'Jyt_test_0310_pre_control';
sub_pre_collection_folder = 'Jyt_test_0310_pre_control_20240310_204214585_data';

subject_name_offline =  'Jyt_test_0310_offline';  % 离线收集数据时候的被试名称
sub_offline_collection_folder = 'Jyt_test_0310_offline_20240310_195952653_data';  % 被试的离线采集数据

channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15, 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道,
mu_channels = struct('C3',24, 'C4',22);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % 用于计算EI指标的几个channels，需要确定下位置的


%% 读取post各种数据，用于后面的显示和显著性分析
% 读取离线实验数据，归一化使用
mu_suppressions_scores = load(fullfile(root_path, sub_offline_collection_folder, ['Offline_EEGMI_Scores_', subject_name_offline], ['Offline_EEGMI_Scores_', subject_name_offline,'.mat']));
mu_suppressions_offline = mu_suppressions_scores.mu_suppressions;
min_max_value = mu_suppressions_scores.min_max_value_mu;

% 读取对比实验的数据
scores_post = load(fullfile(root_path, sub_post_collection_folder,['Offline_EEGMI_Scores_', subject_name_post], ['Offline_EEGMI_Scores_', subject_name_post, '.mat']));
results_post = load(fullfile(root_path, sub_post_collection_folder,['Offline_EEGMI_Scores_', subject_name_post], ['Offline_EEGMI_Results_', subject_name_post, '.mat']));
mu_suppressions_compare_post = scores_post.mu_suppressions;
mu_suppressions_trial_compare_post = scores_post.mu_suppressions_trialmean;
EI_index_scores_compare_post = scores_post.EI_index_scores_trialmean;
resultsMI_compare_post = results_post.resultsMI;
resultsMI_trial_compare_post = mean(reshape(resultsMI_compare_post(1,:), 4, []));  % 计算对比实验组的每一个trial的平均准确率
resultsMI_trial_compare_post = [resultsMI_trial_compare_post; mu_suppressions_trial_compare_post(2,:)];

% 初始化一个空的归一化结果矩阵
mu_suppressions_normalized_compare_post = zeros(size(mu_suppressions_compare_post(1,:)));
% 对每一个Trigger进行归一化
for i = 1:(length(mu_suppressions_normalized_compare_post))
    % 获取当前Trigger
    current_Trigger = mu_suppressions_compare_post(2, i);
    
    % 对当前Trigger对应的数值进行归一化
    mu_suppressions_normalized_compare_post(1, i) = mu_normalization(mu_suppressions_compare_post(1, i), min_max_value, current_Trigger+1);
end
visualfeedback_compare_post = mu_suppressions_normalized_compare_post(1,:).* resultsMI_compare_post(1,:);  % 计算下compare的对比实验
visualfeedback_trial_compare_post = mean(reshape(visualfeedback_compare_post(1,:), 4, []));
visualfeedback_trial_compare_post = [visualfeedback_trial_compare_post(1,:); mu_suppressions_trial_compare_post(2,:)];
mu_suppressions_normalized_compare_trial_post = mean(reshape(mu_suppressions_normalized_compare_post(1,:), 4, []));
mu_suppressions_normalized_compare_trial_post = [mu_suppressions_normalized_compare_trial_post(1,:); mu_suppressions_trial_compare_post(2,:)];

%% 读取pre各种数据，用于后面的显示和显著性分析
% 读取对比实验的数据
scores_pre = load(fullfile(root_path, sub_pre_collection_folder,['Offline_EEGMI_Scores_', subject_name_pre], ['Offline_EEGMI_Scores_', subject_name_pre, '.mat']));
results_pre = load(fullfile(root_path, sub_pre_collection_folder,['Offline_EEGMI_Scores_', subject_name_pre], ['Offline_EEGMI_Results_', subject_name_pre, '.mat']));
mu_suppressions_compare_pre = scores_pre.mu_suppressions;
mu_suppressions_trial_compare_pre = scores_pre.mu_suppressions_trialmean;
EI_index_scores_compare_pre = scores_pre.EI_index_scores_trialmean;
resultsMI_compare_pre = results_pre.resultsMI;
resultsMI_trial_compare_pre = mean(reshape(resultsMI_compare_pre(1,:), 4, []));  % 计算对比实验组的每一个trial的平均准确率
resultsMI_trial_compare_pre = [resultsMI_trial_compare_pre; mu_suppressions_trial_compare_pre(2,:)];

% 初始化一个空的归一化结果矩阵
mu_suppressions_normalized_compare_pre = zeros(size(mu_suppressions_compare_pre(1,:)));
% 对每一个Trigger进行归一化
for i = 1:(length(mu_suppressions_normalized_compare_pre))
    % 获取当前Trigger
    current_Trigger = mu_suppressions_compare_pre(2, i);
    
    % 对当前Trigger对应的数值进行归一化
    mu_suppressions_normalized_compare_pre(1, i) = mu_normalization(mu_suppressions_compare_pre(1, i), min_max_value, current_Trigger+1);
end
visualfeedback_compare_pre = mu_suppressions_normalized_compare_pre(1,:).* resultsMI_compare_pre(1,:);  % 计算下compare的对比实验
visualfeedback_trial_compare_pre = mean(reshape(visualfeedback_compare_pre(1,:), 4, []));
visualfeedback_trial_compare_pre = [visualfeedback_trial_compare_pre(1,:); mu_suppressions_trial_compare_pre(2,:)];
mu_suppressions_normalized_compare_trial_pre = mean(reshape(mu_suppressions_normalized_compare_pre(1,:), 4, []));
mu_suppressions_normalized_compare_trial_pre = [mu_suppressions_normalized_compare_trial_pre(1,:); mu_suppressions_trial_compare_pre(2,:)];

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


%% 显示相关数值，分析显著性
% 绘制mu_suppresions和EI_index_scores的折线图
% figure;
% plot(mu_suppresions(1,:), 'LineWidth', 2);
% hold on;
% plot(mu_suppressions_compare(1,:), 'LineWidth', 2);
% hold off;
% legend('mu suppresions online', 'mu suppresions compare');
% xlabel('Index');
% ylabel('Value');
% title('Line plot of mu suppresions');
% grid on;
% 
% figure;
% plot(EI_index_scores(1,:), 'LineWidth', 2);
% hold on;
% plot(EI_index_scores_compare(1,:), 'LineWidth', 2);
% hold off;
% legend('EI online', 'EI compare');
% xlabel('Index');
% ylabel('Value');
% title('Line plot of EI');
% grid on;
% 
% figure;
% resultsTrigger = resultsMI_trials(2,:);
% plot(mu_suppresions(1,:).* resultsMI_trials(1,:), 'LineWidth', 2);  %.* resultsMI_trials(1,:)
% hold on;
% plot(MI_MUSup_thres_row1(1,:), 'LineWidth', 2);
% hold on;
% plot(resultsMI_trials(1,:), 'LineWidth', 2);
% hold off;
% legend('mu sup online', 'mu sup thre', 'resultsMI');
% xlabel('Index');
% ylabel('Value');
% title('Line plot of thresholds');
% grid on;
% 
% figure;
% resultsTrigger = resultsMI_trials(2,:);
% plot(mu_suppresions(1,resultsTrigger==1).* resultsMI_trials(1,resultsTrigger==1), 'LineWidth', 2);  %.* resultsMI_trials(1,:)
% hold on;
% plot(MI_MUSup_thres_row1(1,resultsTrigger==1), 'LineWidth', 2);
% hold on;
% plot(resultsMI_trials(1,resultsTrigger==1), 'LineWidth', 2);
% hold off;
% legend('mu sup online', 'mu sup thre', 'resultsMI');
% xlabel('Index');
% ylabel('Value');
% title('Line plot of thresholds task 1');
% grid on;
% 
% figure;
% plot(mu_suppresions(1,resultsTrigger==2).* resultsMI_trials(1,resultsTrigger==2), 'LineWidth', 2);  %.* resultsMI_trials(1,:)
% hold on;
% plot(MI_MUSup_thres_row1(1,resultsTrigger==2), 'LineWidth', 2);
% hold on;
% plot(resultsMI_trials(1,resultsTrigger==2), 'LineWidth', 2);
% hold off;
% legend('mu sup online', 'mu sup thre', 'resultsMI');
% xlabel('Index');
% ylabel('Value');
% title('Line plot of thresholds task 2');
% grid on;
% 
% figure;
% resultsTrigger = resultsMI_trials(2,:);
% plot(resultsMI_trials(1,:), 'LineWidth', 2);
% hold on;
% plot(resultsMI_trial_compare, 'LineWidth', 2);
% hold off;
% legend('results MI', 'results MI comparison');
% xlabel('Index');
% ylabel('Value');
% title('Line plot of results of each MI');
% grid on;

% figure;
% plot(visual_feedbacks_trial(1,:), 'LineWidth', 2);
% hold on;
% plot(MI_MUSup_thres_normalized(1,:), 'LineWidth', 2);
% hold off;
% legend('visual_feedback', 'MI_MUSup_thres');
% xlabel('Index');
% ylabel('Value');
% title('Line plot of visual_feedbacks_trial');
% grid on;

% figure;
% envelope_extraction(EI_index_scores(1,:));
% grid on;

%plot_signal_and_fit(EI_index_scores(1,:), 'EI online');
%plot_signal_and_fit(EI_index_scores_compare(1,:), 'EI compare');
subplot(2,2,1);
plot_signal_and_fit_double_linear(visualfeedback_trial_compare_post(1,:), 'visualfeedback', visualfeedback_trial_compare_pre(1,:), 'visualfeedback compare', 'visualfeedback');
subplot(2,2,2);
plot_signal_and_fit_double_linear(resultsMI_trial_compare_post(1,:), 'results', resultsMI_trial_compare_pre(1,:), 'results compare', 'results');
subplot(2,2,3);
plot_signal_and_fit_double_linear(mu_suppressions_normalized_compare_trial_post(1,:), 'Mu sup online', mu_suppressions_normalized_compare_trial_pre(1,:), 'Mu sup compare', 'mu sup');
subplot(2,2,4);
plot_signal_and_fit_double_linear(EI_index_scores_compare_post(1,:), 'EI online', EI_index_scores_compare_pre(1,:), 'EI compare', 'EI');
%suptitle(strrep(subject_name_online, '_', ' '));

disp('methods on visualfeedback');
[p_ttest, p_ranksum] = significance_analysis(visualfeedback_trial_compare_post, visualfeedback_trial_compare_pre);
significance_show(p_ttest,p_ranksum);
disp('methods on mu_suppresions');
[p_ttest, p_ranksum] = significance_analysis(mu_suppressions_normalized_compare_trial_post, mu_suppressions_normalized_compare_trial_pre);
significance_show(p_ttest,p_ranksum);
disp('methods on EI');
[p_ttest, p_ranksum] = significance_analysis(EI_index_scores_compare_post, EI_index_scores_compare_pre);
significance_show(p_ttest,p_ranksum);
disp('methods on resultsMI')
[p_ttest, p_ranksum] = significance_analysis(resultsMI_trial_compare_post, resultsMI_trial_compare_pre);
significance_show(p_ttest,p_ranksum);

disp('methods on mu_suppresions on triggers');
[p_ttest, p_ranksum] = significance_analysis_trigger(mu_suppressions_trial_compare_post, mu_suppressions_trial_compare_pre);
significance_show(p_ttest,p_ranksum);
disp('methods on EI_index_scores on triggers');
[p_ttest, p_ranksum] = significance_analysis_trigger(EI_index_scores_compare_post, EI_index_scores_compare_pre);
significance_show(p_ttest,p_ranksum);
disp('methods on resultsMI on triggers');
[p_ttest, p_ranksum] = significance_analysis_trigger(resultsMI_trial_compare_post, resultsMI_trial_compare_pre);
significance_show(p_ttest,p_ranksum);



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
        %mu_suppresions = [mu_suppresions, [max(mu_suppresion); Trigger]];
        %mu_suppresions = [mu_suppresions, [mu_suppresion(end); Trigger]];
        %mu_suppresions = [mu_suppresions, [mean(mu_suppresion(end)); Trigger]];
        
        % 计算EI_index_score
        EI_index_score = zeros(1, size(EI_indices, 2));
        for j = 1:size(EI_indices, 2)
            EI_index = EI_indices(:,j);
            EI_index_score(j) = EI_index_Caculation(EI_index, EI_channels);
        end
        
        % 计算EI_index_score的均值并保存
        %EI_index_scores = [EI_index_scores, [EI_index_score; repmat(Trigger,1,size(mu_powers, 2))]];
        EI_index_scores = [EI_index_scores, [mean(EI_index_score); Trigger]];
        %EI_index_scores = [EI_index_scores, [max(EI_index_score); Trigger]];
        
        % 计算分类概率在这一个trial里面的均值
        resultsMI_trials = [resultsMI_trials, [mean(resultsMI(1,:)); Trigger]];
        %resultsMI_trials = [resultsMI_trials, [max(resultsMI(1,:)); Trigger]];
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
%% 用于绘制提取包络线的函数
function envelope_extraction(x, experiment_name)
    
    fl1 = 1000;
    [up1,lo1] = envelope(x,fl1,'analytic');
    plot_param = {'Color', [0.6 0.1 0.2],'Linewidth',2}; 
    
    plot(x)
    hold on
    plot(up1,plot_param{:});
    plot(lo1,plot_param{:});

    hold off
    title('Hilbert Envelope')

end
%% 用于最小二次拟合的函数
function plot_signal_and_fit(y, experiment_name, score_name)
    % 创建一个 x 轴的值，从 1 到信号的长度
    x = 1:length(y);

    % 使用 polyfit 函数进行最小二次拟合
    p = polyfit(x, y, 2);

    % 创建一个函数句柄，用于计算拟合的二次函数
    f = @(x) p(1) * x.^2 + p(2) * x + p(3);

    % 计算拟合的二次函数
    y_fit = f(x);

    % 绘制原始数据和拟合的二次函数
    figure;
    plot(y);
    hold on;
    plot(x, y_fit, '-');
    hold on;
    hold off;

    % 添加图例和标题
    legend(['Original Signal', experiment_name], ['Quadratic Fit', experiment_name]);
    title(['Original Signal and Quadratic Fit: ', score_name]);
end

function plot_signal_and_fit_double(y1, experiment_name1, y2, experiment_name2, score_name)
    % 创建一个 x 轴的值，从 1 到信号的长度
    x1 = 1:length(y1);
    x2 = 1:length(y2);
    

    % 使用 polyfit 函数进行最小二次拟合
    p1 = polyfit(x1, y1, 2);
    p2 = polyfit(x2, y2, 2);

    % 创建一个函数句柄，用于计算拟合的二次函数
    f1 = @(x) p1(1) * x.^2 + p1(2) * x + p1(3);
    f2 = @(x) p2(1) * x.^2 + p2(2) * x + p2(3);

    % 计算拟合的二次函数
    y_fit1 = f1(x1);
    y_fit2 = f2(x2);

    % 绘制原始数据和拟合的二次函数
    %figure;
    plot(y1);
    hold on;
    plot(x1, y_fit1, '-');
    hold on;
    plot(y2);
    hold on;
    plot(x2, y_fit2, '-');
    hold on;
    hold off;

    % 添加图例和标题
%     legend(['Original Signal ', experiment_name1], ['Quadratic Fit ', experiment_name1],...
%         ['Original Signal ', experiment_name2], ['Quadratic Fit ', experiment_name2]);
%     title(['Original Signal and Quadratic Fit: ', score_name]);
    legend([experiment_name1], [experiment_name1],...
         [experiment_name2], [experiment_name2]);
     title(['Original Signal and Quadratic Fit: ', score_name]);
end

function plot_signal_and_fit_double_linear(y1, experiment_name1, y2, experiment_name2, score_name)
    % 创建一个 x 轴的值，从 1 到信号的长度
    x1 = 1:length(y1);
    x2 = 1:length(y2);
    

    % 使用 polyfit 函数进行最小一次拟合
    p1 = polyfit(x1, y1, 1);
    p2 = polyfit(x2, y2, 1);

    % 创建一个函数句柄，用于计算拟合的一次函数
    f1 = @(x) p1(1) * x + p1(2);
    f2 = @(x) p2(1) * x + p2(2);

    % 计算拟合的一次函数
    y_fit1 = f1(x1);
    y_fit2 = f2(x2);

    % 绘制原始数据和拟合的一次函数
    %figure;
    plot(y1);
    hold on;
    plot(x1, y_fit1, 'LineWidth', 2);
    hold on;
    plot(y2);
    hold on;
    plot(x2, y_fit2, 'LineWidth', 2);
    hold off;

    % 添加图例和标题
    legend([experiment_name1], [experiment_name1],...
         [experiment_name2], [experiment_name2]);
     title(['Original Signal and Linear Fit: ', score_name]);
end

%% 归一化显示的函数，主要用于归一化的函数显示
function mu_normalized = mu_normalization(mu_data, min_max_value, Trigger)
    % 提取最大和最小数值
    data_max = min_max_value(1, Trigger);
    data_min = min_max_value(2, Trigger);
    % 归一化相关的数据，使得其在0到1的范围内
    mu_normalized = (mu_data - data_min)/(data_max - data_min);
end