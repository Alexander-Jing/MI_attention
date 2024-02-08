%% 被试名称和实验的文件夹
root_path = 'F:\CASIA\MI_engagement\MI_attention\MI_Training';  % 根目录用于存储数据和分析
subject_name_comparison = 'Jyt_test_0205_comparison_22';
sub_comparison_collection_folder = 'Jyt_test_0205_comparison_22_20240205_220245054_data';

channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15, 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道,
mu_channels = struct('C3',24, 'C4',22);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % 用于计算EI指标的几个channels，需要确定下位置的

% 通信设置
ip = '172.18.22.21';
port = 8888;  % 和后端服务器连接的两个参数

%% 读取各种数据，用于后面的显示和显著性分析
% 读取对比实验的数据scores
scores_compare = load(fullfile(root_path, sub_comparison_collection_folder,['Offline_EEGMI_Scores_', subject_name_comparison], ['Offline_EEGMI_Scores_', subject_name_comparison, '.mat']));
mu_suppressions_trial = scores_compare.mu_suppressions;
mu_suppressions_trial_compare = scores_compare.mu_suppressions_trialmean;
EI_index_scores_compare = scores_compare.EI_index_scores_trialmean;
% 读取对比实验的rawdata
trialdata_compare_path = fullfile(root_path, sub_comparison_collection_folder, ['Offline_EEGMI_RawData_', subject_name_comparison]);
trialdata_compare_files = dir(fullfile(trialdata_compare_path, '*.mat'));
trialdata_compare_file = trialdata_compare_files(1).name;
trialdata_compare = load(fullfile(trialdata_compare_path, trialdata_compare_file));
rawdata_compare = trialdata_compare.TrialData;

%% 读取在线的rawdata，用于一个伪在线的识别，从而得到在线的识别准确率
trial_length = 15;  % trial时长15s
trial_nums = 14;  %总共14个trial
MI_start = 2;  % MI开始记录的时刻
MI_length = 7-2;  % MI所用的时间长度
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
        config_data = [window_length * sample_freq;size(channels, 2);Trigger;session_idx;trial_idx;MI_idx;1.0;0;0;0;0 ];  %按照相关数值配置好服务器发送
        order = 4.0;
        resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name_comparison, config_data, fullfile(root_path, sub_comparison_collection_folder));  % 传输数据给线上的模型，看分类情况
        disp(['trial: ', num2str(trial_idx)])
        disp(['window: ', num2str(MI_idx)])
        disp(['predict cls: ', num2str(resultMI(1,1))]);
        disp(['cls prob: ', num2str(resultMI(2,1))]);
        resultsMI = [resultsMI, [resultMI(2,1);Trigger]];
        pause(3);
    end
end

foldername_Results = fullfile(root_path, sub_comparison_collection_folder,['Offline_EEGMI_Scores_', subject_name_comparison]); % 指定文件夹路径和名称
if ~exist(foldername_Results, 'dir')
   mkdir(foldername_Results);
end
save([foldername_Results, '\\', ['Offline_EEGMI_Results_', subject_name_comparison], '.mat' ],'resultsMI','mu_suppressions_trial'); 


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

    % 添加图例和标题
    legend(['Original Signal ', experiment_name1], ['Quadratic Fit ', experiment_name1],...
        ['Original Signal ', experiment_name2], ['Quadratic Fit ', experiment_name2]);
    title(['Original Signal and Quadratic Fit: ', score_name]);
end
