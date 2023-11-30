%% 其余两个指标
mean_scores = [1.90526284707639,0.785029282805970,0.580458876670467];
class_accuracies = [0;1;0.333333333333333];

task_weights = [3,5,2];
%% 制作一个UI界面，用于帮助确认难度
% 创建一个输入对话框
prompt = cell(n, 1);
for i = 1:n
    prompt{i} = ['Enter the difficulty level of task ', task_dict(i-1), ', from 0 to ', num2str(n-1), ' (easy to hard)'];
end
dlgtitle = 'Input';
dims = [1 80];

% 显示对话框并获取用户输入
user_input = inputdlg(prompt,dlgtitle,dims);

% 将用户输入的字符数组转换为数值
difficulty_levels = cellfun(@str2double, user_input);

%% 计算综合难度并且显示
[sum_result, sorted_indices] = difficulty_weighted_sum(1.0 - class_accuracies', mean_scores, difficulty_levels', task_weights);
disp('任务难度综合加权难度评分是：');
for i = 1:length(sum_result)
    disp(['任务 ', task_dict(i-1), ' 的平均分数是 ' num2str(sum_result(i))]);
end
disp('综合排序是(由易到难)：');
for i = 1:length(sorted_indices)
    disp(['任务 ', task_dict(sorted_indices(i)-1)]);
end


%% 计算综合加权难度的函数
function [sum_result, sorted_indices] = difficulty_weighted_sum(class_accuracies, mean_scores, difficulty_levels, weights)
    % 对于不同的变量进行归一化，然后计算加权和，最后显示出计算结果
    % 归一化变量
    class_accuracies = class_accuracies / sum(class_accuracies);
    mean_scores = mean_scores / sum(mean_scores);
    difficulty_levels = difficulty_levels / sum(difficulty_levels);

    % 归一化权重
    weights = weights / sum(weights);

    % 加权求和
    sum_result = weights(1) * class_accuracies + weights(2) * mean_scores + weights(3) * difficulty_levels;

    % 按照从小到大的顺序显示结果的序号
    [~, sorted_indices] = sort(sum_result);
end
