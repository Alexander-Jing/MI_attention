%% �������ƺ�ʵ����ļ���
root_path = 'F:\CASIA\MI_engagement\MI_attention\MI_Training';  % ��Ŀ¼���ڴ洢���ݺͷ���
subject_name_comparison = 'Jyt_test_0205_comparison_22';
sub_comparison_collection_folder = 'Jyt_test_0205_comparison_22_20240205_220245054_data';

channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15, 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��,
mu_channels = struct('C3',24, 'C4',22);  % ���ڼ���ERD/ERS�ļ���channels����C3��C4����ͨ��,��Ҫ�趨λ��
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�

% ͨ������
ip = '172.18.22.21';
port = 8888;  % �ͺ�˷��������ӵ���������

%% ��ȡ�������ݣ����ں������ʾ�������Է���
% ��ȡ�Ա�ʵ�������scores
scores_compare = load(fullfile(root_path, sub_comparison_collection_folder,['Offline_EEGMI_Scores_', subject_name_comparison], ['Offline_EEGMI_Scores_', subject_name_comparison, '.mat']));
mu_suppressions_trial = scores_compare.mu_suppressions;
mu_suppressions_trial_compare = scores_compare.mu_suppressions_trialmean;
EI_index_scores_compare = scores_compare.EI_index_scores_trialmean;
% ��ȡ�Ա�ʵ���rawdata
trialdata_compare_path = fullfile(root_path, sub_comparison_collection_folder, ['Offline_EEGMI_RawData_', subject_name_comparison]);
trialdata_compare_files = dir(fullfile(trialdata_compare_path, '*.mat'));
trialdata_compare_file = trialdata_compare_files(1).name;
trialdata_compare = load(fullfile(trialdata_compare_path, trialdata_compare_file));
rawdata_compare = trialdata_compare.TrialData;

%% ��ȡ���ߵ�rawdata������һ��α���ߵ�ʶ�𣬴Ӷ��õ����ߵ�ʶ��׼ȷ��
trial_length = 15;  % trialʱ��15s
trial_nums = 14;  %�ܹ�14��trial
MI_start = 2;  % MI��ʼ��¼��ʱ��
MI_length = 7-2;  % MI���õ�ʱ�䳤��
sample_freq = 256;
window_length = 2;
Trigger = 2;
session_idx = 1;
resultsMI = [];

for trial_idx = 1:trial_nums
    rawdata_trial = rawdata_compare(:, 1 + (trial_idx-1) * trial_length * sample_freq: trial_idx * trial_length * sample_freq);
    window_num = MI_length - window_length + 1;
    for MI_idx = 1:window_num   
        rawdata_MI = rawdata_trial(:, 1 + (MI_start + (MI_idx - 1) * window_length) * sample_freq:(MI_start + MI_idx * window_length) * sample_freq);
        %Trigger = unique(rawdata_MI(end,:));
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(rawdata_MI, Trigger, sample_freq, window_length * sample_freq, channels);
        config_data = [window_length * sample_freq;size(channels, 2);Trigger;session_idx;trial_idx;MI_idx;1.0;0;0;0;0 ];  %���������ֵ���ú÷���������
        order = 4.0;
        resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name_comparison, config_data, fullfile(root_path, sub_comparison_collection_folder));  % �������ݸ����ϵ�ģ�ͣ����������
        disp(['trial: ', num2str(trial_idx)])
        disp(['window: ', num2str(MI_idx)])
        disp(['predict cls: ', num2str(resultMI(1,1))]);
        disp(['cls prob: ', num2str(resultMI(2,1))]);
        resultsMI = [resultsMI, [resultMI(2,1);Trigger]];
        pause(3);
    end
end

foldername_Results = fullfile(root_path, sub_comparison_collection_folder,['Offline_EEGMI_Scores_', subject_name_comparison]); % ָ���ļ���·��������
if ~exist(foldername_Results, 'dir')
   mkdir(foldername_Results);
end
save([foldername_Results, '\\', ['Offline_EEGMI_Results_', subject_name_comparison], '.mat' ],'resultsMI','mu_suppressions_trial'); 


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
        
        % ��������ӵ�data������
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

    % ���ͼ���ͱ���
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
    figure;
    plot(y1);
    hold on;
    plot(x1, y_fit1, '-');
    hold on;
    plot(y2);
    hold on;
    plot(x2, y_fit2, '-');
    hold on;
    hold off;

    % ���ͼ���ͱ���
    legend(['Original Signal ', experiment_name1], ['Quadratic Fit ', experiment_name1],...
        ['Original Signal ', experiment_name2], ['Quadratic Fit ', experiment_name2]);
    title(['Original Signal and Quadratic Fit: ', score_name]);
end
