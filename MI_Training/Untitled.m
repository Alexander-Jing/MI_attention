%% 读取各种数据，用于后面的显示和显著性分析
% 读取对比实验的数据
scores_pre = load(fullfile(root_path, sub_post_collection_folder,['Offline_EEGMI_Scores_', subject_name_pre], ['Offline_EEGMI_Scores_', subject_name_pre, '.mat']));
results_pre = load(fullfile(root_path, sub_post_collection_folder,['Offline_EEGMI_Scores_', subject_name_pre], ['Offline_EEGMI_Results_', subject_name_pre, '.mat']));
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
