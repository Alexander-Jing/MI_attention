%% �������ƺ�ʵ����ļ���
root_path = 'F:\CASIA\MI_engagement\MI_attention\MI_Training';  % ��Ŀ¼���ڴ洢���ݺͷ���
subject_name_post = 'Jyt_test_0310_post_control'; %'Jyt_test_0101_1_online';% 'Jyt_test_0101_online'; %  % ��������
sub_post_collection_folder = 'Jyt_test_0310_post_control_20240310_212613989_data';

subject_name_pre = 'Jyt_test_0310_pre_control';
sub_pre_collection_folder = 'Jyt_test_0310_pre_control_20240310_204214585_data';

subject_name_offline =  'Jyt_test_0310_offline';  % �����ռ�����ʱ��ı�������
sub_offline_collection_folder = 'Jyt_test_0310_offline_20240310_195952653_data';  % ���Ե����߲ɼ�����

channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15, 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��,
mu_channels = struct('C3',24, 'C4',22);  % ���ڼ���ERD/ERS�ļ���channels����C3��C4����ͨ��,��Ҫ�趨λ��
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�


%% ��ȡpost�������ݣ����ں������ʾ�������Է���
% ��ȡ����ʵ�����ݣ���һ��ʹ��
mu_suppressions_scores = load(fullfile(root_path, sub_offline_collection_folder, ['Offline_EEGMI_Scores_', subject_name_offline], ['Offline_EEGMI_Scores_', subject_name_offline,'.mat']));
mu_suppressions_offline = mu_suppressions_scores.mu_suppressions;
min_max_value = mu_suppressions_scores.min_max_value_mu;

% ��ȡ�Ա�ʵ�������
scores_post = load(fullfile(root_path, sub_post_collection_folder,['Offline_EEGMI_Scores_', subject_name_post], ['Offline_EEGMI_Scores_', subject_name_post, '.mat']));
results_post = load(fullfile(root_path, sub_post_collection_folder,['Offline_EEGMI_Scores_', subject_name_post], ['Offline_EEGMI_Results_', subject_name_post, '.mat']));
mu_suppressions_compare_post = scores_post.mu_suppressions;
mu_suppressions_trial_compare_post = scores_post.mu_suppressions_trialmean;
EI_index_scores_compare_post = scores_post.EI_index_scores_trialmean;
resultsMI_compare_post = results_post.resultsMI;
resultsMI_trial_compare_post = mean(reshape(resultsMI_compare_post(1,:), 4, []));  % ����Ա�ʵ�����ÿһ��trial��ƽ��׼ȷ��
resultsMI_trial_compare_post = [resultsMI_trial_compare_post; mu_suppressions_trial_compare_post(2,:)];

% ��ʼ��һ���յĹ�һ���������
mu_suppressions_normalized_compare_post = zeros(size(mu_suppressions_compare_post(1,:)));
% ��ÿһ��Trigger���й�һ��
for i = 1:(length(mu_suppressions_normalized_compare_post))
    % ��ȡ��ǰTrigger
    current_Trigger = mu_suppressions_compare_post(2, i);
    
    % �Ե�ǰTrigger��Ӧ����ֵ���й�һ��
    mu_suppressions_normalized_compare_post(1, i) = mu_normalization(mu_suppressions_compare_post(1, i), min_max_value, current_Trigger+1);
end
visualfeedback_compare_post = mu_suppressions_normalized_compare_post(1,:).* resultsMI_compare_post(1,:);  % ������compare�ĶԱ�ʵ��
visualfeedback_trial_compare_post = mean(reshape(visualfeedback_compare_post(1,:), 4, []));
visualfeedback_trial_compare_post = [visualfeedback_trial_compare_post(1,:); mu_suppressions_trial_compare_post(2,:)];
mu_suppressions_normalized_compare_trial_post = mean(reshape(mu_suppressions_normalized_compare_post(1,:), 4, []));
mu_suppressions_normalized_compare_trial_post = [mu_suppressions_normalized_compare_trial_post(1,:); mu_suppressions_trial_compare_post(2,:)];

%% ��ȡpre�������ݣ����ں������ʾ�������Է���
% ��ȡ�Ա�ʵ�������
scores_pre = load(fullfile(root_path, sub_pre_collection_folder,['Offline_EEGMI_Scores_', subject_name_pre], ['Offline_EEGMI_Scores_', subject_name_pre, '.mat']));
results_pre = load(fullfile(root_path, sub_pre_collection_folder,['Offline_EEGMI_Scores_', subject_name_pre], ['Offline_EEGMI_Results_', subject_name_pre, '.mat']));
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

%% ��ȡ��������/���߶Ա�ʵ���е����ݣ����Ҽ����һЩ��ص�ָ�꣨���ô��룬ƽʱ���أ�
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


%% ��ʾ�����ֵ������������
% ����mu_suppresions��EI_index_scores������ͼ
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

%% ��ȡ���ߵ��ļ��е�ÿһ������
function [mu_suppresions, EI_index_scores, resultsMI_trials] = mu_EI_MIresult_caculation(folder_path, mu_channels, EI_channels)
    % �л���ָ�����ļ���
    cd(folder_path);
    
    % ��ȡ�ļ����е�����.mat�ļ�
    files = dir('*.mat');
    
    % ��ȡ���ļ����е�c��ֵ����ת��Ϊ����
    c_values = cellfun(@(x) str2double(regexp(x, 'trial_(\d+)', 'tokens', 'once')), {files.name});
    
    % ����c��ֵ���ļ���������
    [~, index] = sort(c_values);
    files = files(index);
    
    % ��ʼ��mu_suppresions��EI_index_scores
    mu_suppresions = [];
    EI_index_scores = [];
    resultsMI_trials = [];
    
    % ����ÿ���ļ�
    for i = 1:length(files)
        % ����.mat�ļ�
        data = load(files(i).name);
        
        % ��ȡmu_powers��EI_indices
        mu_powers = data.mu_powers;
        EI_indices = data.EI_indices;
        % ��ȡ�������
        resultsMI = data.resultsMI;
        
        % ��ȡmu_power_��mu_power
        mu_power_ = mu_powers(:,1);
        mu_powers = mu_powers(:,2:end);
        
        resultsMI = resultsMI(2:end,:);
        
        % ����mu_suppresion
        mu_suppresion = zeros(1, size(mu_powers, 2));
        Trigger = mu_powers(33,1);
        for j = 1:size(mu_powers, 2)
            mu_power = mu_powers(:,j);
            mu_suppresion(j) = MI_MuSuperesion(mu_power_, mu_power, mu_channels);
        end
        
        % ����mu_suppresion�ľ�ֵ������
        %mu_suppresions = [mu_suppresions, [mu_suppresion; repmat(Trigger,1,size(mu_powers, 2))]];
        mu_suppresions = [mu_suppresions, [mean(mu_suppresion); Trigger]];
        %mu_suppresions = [mu_suppresions, [max(mu_suppresion); Trigger]];
        %mu_suppresions = [mu_suppresions, [mu_suppresion(end); Trigger]];
        %mu_suppresions = [mu_suppresions, [mean(mu_suppresion(end)); Trigger]];
        
        % ����EI_index_score
        EI_index_score = zeros(1, size(EI_indices, 2));
        for j = 1:size(EI_indices, 2)
            EI_index = EI_indices(:,j);
            EI_index_score(j) = EI_index_Caculation(EI_index, EI_channels);
        end
        
        % ����EI_index_score�ľ�ֵ������
        %EI_index_scores = [EI_index_scores, [EI_index_score; repmat(Trigger,1,size(mu_powers, 2))]];
        EI_index_scores = [EI_index_scores, [mean(EI_index_score); Trigger]];
        %EI_index_scores = [EI_index_scores, [max(EI_index_score); Trigger]];
        
        % ��������������һ��trial����ľ�ֵ
        resultsMI_trials = [resultsMI_trials, [mean(resultsMI(1,:)); Trigger]];
        %resultsMI_trials = [resultsMI_trials, [max(resultsMI(1,:)); Trigger]];
    end
end
%% ��ȡƽ������ȷ����ĺ���
function mean_std_scores = compute_mean_std(scores_task, scores_name)
    % ��ȡscores��triggers
    scores = scores_task(1,:);
    triggers = scores_task(2,:);

    % ��ȡ���в�ͬ��triggers
    unique_triggers = unique(triggers);

    % ��ʼ�����
    mean_scores = zeros(size(unique_triggers));
    std_scores = zeros(size(unique_triggers));

    % ����ÿһ��trigger�������Ӧ��score�ľ�ֵ
    for i = 1:length(unique_triggers)
        trigger = unique_triggers(i);
        mean_scores(i) = mean(scores(triggers == trigger));
        std_scores(i) = std(scores(triggers == trigger));
    end
    mean_std_scores = [mean_scores; std_scores];

    % ������
    disp(['ÿһ��Trigger��ƽ��', scores_name, '�����ǣ�']);
    for i = 1:length(unique_triggers)
        disp(['Trigger ' num2str(unique_triggers(i)) ' ��ƽ�������� ' num2str(mean_scores(i))]);
        disp(['Trigger ' num2str(unique_triggers(i)) ' �ı�׼���� ' num2str(std_scores(i))]);
    end
end

%% �������muƵ��˥��ָ��
function mu_suppresion = MI_MuSuperesion(mu_power_, mu_power, mu_channels)
    ERD_C3 = (mu_power(mu_channels.C3, 1) - mu_power_(mu_channels.C3, 1)); 
    %ERD_C4 = (mu_power(mu_channels.C4, 1) - mu_power_(mu_channels.C4, 1));  % ���������Ե�λ�õ���ص�ָ�� 
    mu_suppresion = - ERD_C3;  % ��һ����[0,1]����������
end
    
%% ������ص�EIָ��ĺ���
function EI_index_score = EI_index_Caculation(EI_index, EI_channels)
    channels_ = [EI_channels.Fp1,EI_channels.Fp2, EI_channels.F7, EI_channels.F3, EI_channels.Fz, EI_channels.F4, EI_channels.F8'];
    EI_index_score = mean(EI_index(channels_, 1));

end

%% ���������Եĺ���
function [p_ttest, p_ranksum] = significance_analysis_trigger(mu_suppresions1, mu_suppresions2)
    % ��ȡ����Ψһֵ
    categories = unique(mu_suppresions1(2,:));

    % ��ʼ��pֵ
    p_ttest = zeros(1, length(categories));
    p_ranksum = zeros(1, length(categories));

    % ��ÿ�������������Է���
    for i = 1:length(categories)
        % ��ȡ��ǰ���
        category = categories(i);
        
        % ��ȡ����ǰ��������
        data1 = mu_suppresions1(1, mu_suppresions1(2,:) == category);
        data2 = mu_suppresions2(1, mu_suppresions2(2,:) == category);
        
        % ����t����
        [~,p_ttest(i)] = ttest2(data1, data2);
        
        % ����Wilcoxon�Ⱥͼ���
        p_ranksum(i) = ranksum(data1, data2);
    end
end

function [p_ttest, p_ranksum] = significance_analysis(mu_suppresions1, mu_suppresions2)
    
    % ��ʼ��pֵ
    p_ttest = zeros(1, 1);
    p_ranksum = zeros(1, 1);

    % ��ȡ����ǰ��������
    data1 = mu_suppresions1(1, :);
    data2 = mu_suppresions2(1, :);
        
    % ����t����
    [~,p_ttest(1)] = ttest2(data1, data2);

    % ����Wilcoxon�Ⱥͼ���
    p_ranksum(1) = ranksum(data1, data2);
    
end

function [p_anova] = anova_analysis(mu_suppresions1, mu_suppresions2)
    % ��ȡ����Ψһֵ
    categories = unique([mu_suppresions1(2,:), mu_suppresions2(2,:)]);
    %categories = [2];
    % ��ʼ������
    data = [];
    group = [];

    % ��ÿ�������д���
    for i = 1:length(categories)
        % ��ȡ��ǰ���
        category = categories(i);
        
        % ��ȡ����ǰ��������
        data1 = mu_suppresions1(1, mu_suppresions1(2,:) == category);
        data2 = mu_suppresions2(1, mu_suppresions2(2,:) == category);
        
        % ���������ӵ�data������
        data = [data, data1, data2];
        
        % ����һ�����ǩ����
        group = [group, repmat({sprintf('Method1_Category%d', category)}, 1, length(data1)), ...
                         repmat({sprintf('Method2_Category%d', category)}, 1, length(data2))];
    end
    
    % ���з������
    p_anova = anova1(data, group, 'off'); % 'off'��ʾ����ʾ���ͼ��
end
% ��ʾ���������������
function significance_show(p_ttest,p_ranksum)
    for i = 1:length(p_ttest)
        fprintf('Category %d: p_ttest = %.4f, p_ranksum = %.4f\n', i, p_ttest(i), p_ranksum(i));
        if p_ttest(i) < 0.05
            fprintf('����t���飬���%d�Ĳ����������ġ�\n', i);
        else
            fprintf('����t���飬���%d�Ĳ��첻�������ġ�\n', i);
        end
        if p_ranksum(i) < 0.05
            fprintf('����Wilcoxon�Ⱥͼ��飬���%d�Ĳ����������ġ�\n', i);
        else
            fprintf('����Wilcoxon�Ⱥͼ��飬���%d�Ĳ��첻�������ġ�\n', i);
        end
    end
end
%% ��������Եĺ���
function [correlation, p_value] = display_correlation(data1, data2)
    % �������ϵ����pֵ
    [R, P] = corrcoef(data1(1,:), data2(1,:));

    % ��ȡ���ϵ����pֵ
    correlation = R(1, 2);
    p_value = P(1, 2);

    % ��ʾ���ϵ����pֵ
    fprintf('The correlation coefficient (r) between the two datasets is: %.4f\n', correlation);
    fprintf('The p-value for this correlation is: %.4f\n', p_value);
end

function [R, P] = display_correlation_trigger(mu_suppresions1, mu_suppresions2)
    % ��ȡ����Ψһֵ
    categories = unique(mu_suppresions1(2,:));

    % ��ʼ��pֵ
    R = zeros(1, length(categories));
    P = zeros(1, length(categories));

    % ��ÿ�������������Է���
    for i = 1:length(categories)
        % ��ȡ��ǰ���
        category = categories(i);
        disp(['category: ', num2str(category)]);
        % ��ȡ����ǰ��������
        data1 = mu_suppresions1(1, mu_suppresions1(2,:) == category);
        data2 = mu_suppresions2(1, mu_suppresions2(2,:) == category);
        
        % ��������Լ������
        [R(i), P(i)] = display_correlation(data1, data2);
    end
end
%% ���ڻ�����ȡ�����ߵĺ���
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
%% ������С������ϵĺ���
function plot_signal_and_fit(y, experiment_name, score_name)
    % ����һ�� x ���ֵ���� 1 ���źŵĳ���
    x = 1:length(y);

    % ʹ�� polyfit ����������С�������
    p = polyfit(x, y, 2);

    % ����һ��������������ڼ�����ϵĶ��κ���
    f = @(x) p(1) * x.^2 + p(2) * x + p(3);

    % ������ϵĶ��κ���
    y_fit = f(x);

    % ����ԭʼ���ݺ���ϵĶ��κ���
    figure;
    plot(y);
    hold on;
    plot(x, y_fit, '-');
    hold on;
    hold off;

    % ����ͼ���ͱ���
    legend(['Original Signal', experiment_name], ['Quadratic Fit', experiment_name]);
    title(['Original Signal and Quadratic Fit: ', score_name]);
end

function plot_signal_and_fit_double(y1, experiment_name1, y2, experiment_name2, score_name)
    % ����һ�� x ���ֵ���� 1 ���źŵĳ���
    x1 = 1:length(y1);
    x2 = 1:length(y2);
    

    % ʹ�� polyfit ����������С�������
    p1 = polyfit(x1, y1, 2);
    p2 = polyfit(x2, y2, 2);

    % ����һ��������������ڼ�����ϵĶ��κ���
    f1 = @(x) p1(1) * x.^2 + p1(2) * x + p1(3);
    f2 = @(x) p2(1) * x.^2 + p2(2) * x + p2(3);

    % ������ϵĶ��κ���
    y_fit1 = f1(x1);
    y_fit2 = f2(x2);

    % ����ԭʼ���ݺ���ϵĶ��κ���
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

    % ����ͼ���ͱ���
%     legend(['Original Signal ', experiment_name1], ['Quadratic Fit ', experiment_name1],...
%         ['Original Signal ', experiment_name2], ['Quadratic Fit ', experiment_name2]);
%     title(['Original Signal and Quadratic Fit: ', score_name]);
    legend([experiment_name1], [experiment_name1],...
         [experiment_name2], [experiment_name2]);
     title(['Original Signal and Quadratic Fit: ', score_name]);
end

function plot_signal_and_fit_double_linear(y1, experiment_name1, y2, experiment_name2, score_name)
    % ����һ�� x ���ֵ���� 1 ���źŵĳ���
    x1 = 1:length(y1);
    x2 = 1:length(y2);
    

    % ʹ�� polyfit ����������Сһ�����
    p1 = polyfit(x1, y1, 1);
    p2 = polyfit(x2, y2, 1);

    % ����һ��������������ڼ�����ϵ�һ�κ���
    f1 = @(x) p1(1) * x + p1(2);
    f2 = @(x) p2(1) * x + p2(2);

    % ������ϵ�һ�κ���
    y_fit1 = f1(x1);
    y_fit2 = f2(x2);

    % ����ԭʼ���ݺ���ϵ�һ�κ���
    %figure;
    plot(y1);
    hold on;
    plot(x1, y_fit1, 'LineWidth', 2);
    hold on;
    plot(y2);
    hold on;
    plot(x2, y_fit2, 'LineWidth', 2);
    hold off;

    % ����ͼ���ͱ���
    legend([experiment_name1], [experiment_name1],...
         [experiment_name2], [experiment_name2]);
     title(['Original Signal and Linear Fit: ', score_name]);
end

%% ��һ����ʾ�ĺ�������Ҫ���ڹ�һ���ĺ�����ʾ
function mu_normalized = mu_normalization(mu_data, min_max_value, Trigger)
    % ��ȡ������С��ֵ
    data_max = min_max_value(1, Trigger);
    data_min = min_max_value(2, Trigger);
    % ��һ����ص����ݣ�ʹ������0��1�ķ�Χ��
    mu_normalized = (mu_data - data_min)/(data_max - data_min);
end