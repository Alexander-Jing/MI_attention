%% ��ȡ�������ݣ����ں������ʾ�������Է���
% ��ȡ�Ա�ʵ�������
scores_pre = load(fullfile(root_path, sub_post_collection_folder,['Offline_EEGMI_Scores_', subject_name_pre], ['Offline_EEGMI_Scores_', subject_name_pre, '.mat']));
results_pre = load(fullfile(root_path, sub_post_collection_folder,['Offline_EEGMI_Scores_', subject_name_pre], ['Offline_EEGMI_Results_', subject_name_pre, '.mat']));
mu_suppressions_compare_pre = scores_pre.mu_suppressions;
mu_suppressions_trial_compare_pre = scores_pre.mu_suppressions_trialmean;
EI_index_scores_compare_pre = scores_pre.EI_index_scores_trialmean;
resultsMI_compare_pre = results_pre.resultsMI;
resultsMI_trial_compare_pre = mean(reshape(resultsMI_compare_pre(1,:), 4, []));  % ����Ա�ʵ�����ÿһ��trial��ƽ��׼ȷ��
resultsMI_trial_compare_pre = [resultsMI_trial_compare_pre; mu_suppressions_trial_compare_pre(2,:)];

% ��ʼ��һ���յĹ�һ���������
mu_suppressions_normalized_compare_pre = zeros(size(mu_suppressions_compare_pre(1,:)));
% ��ÿһ��Trigger���й�һ��
for i = 1:(length(mu_suppressions_normalized_compare_pre))
    % ��ȡ��ǰTrigger
    current_Trigger = mu_suppressions_compare_pre(2, i);
    
    % �Ե�ǰTrigger��Ӧ����ֵ���й�һ��
    mu_suppressions_normalized_compare_pre(1, i) = mu_normalization(mu_suppressions_compare_pre(1, i), min_max_value, current_Trigger+1);
end
visualfeedback_compare_pre = mu_suppressions_normalized_compare_pre(1,:).* resultsMI_compare_pre(1,:);  % ������compare�ĶԱ�ʵ��
visualfeedback_trial_compare_pre = mean(reshape(visualfeedback_compare_pre(1,:), 4, []));
visualfeedback_trial_compare_pre = [visualfeedback_trial_compare_pre(1,:); mu_suppressions_trial_compare_pre(2,:)];
mu_suppressions_normalized_compare_trial_pre = mean(reshape(mu_suppressions_normalized_compare_pre(1,:), 4, []));
mu_suppressions_normalized_compare_trial_pre = [mu_suppressions_normalized_compare_trial_pre(1,:); mu_suppressions_trial_compare_pre(2,:)];
