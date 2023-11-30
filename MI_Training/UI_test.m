%% ��������ָ��
mean_scores = [1.90526284707639,0.785029282805970,0.580458876670467];
class_accuracies = [0;1;0.333333333333333];

task_weights = [3,5,2];
%% ����һ��UI���棬���ڰ���ȷ���Ѷ�
% ����һ������Ի���
prompt = cell(n, 1);
for i = 1:n
    prompt{i} = ['Enter the difficulty level of task ', task_dict(i-1), ', from 0 to ', num2str(n-1), ' (easy to hard)'];
end
dlgtitle = 'Input';
dims = [1 80];

% ��ʾ�Ի��򲢻�ȡ�û�����
user_input = inputdlg(prompt,dlgtitle,dims);

% ���û�������ַ�����ת��Ϊ��ֵ
difficulty_levels = cellfun(@str2double, user_input);

%% �����ۺ��ѶȲ�����ʾ
[sum_result, sorted_indices] = difficulty_weighted_sum(1.0 - class_accuracies', mean_scores, difficulty_levels', task_weights);
disp('�����Ѷ��ۺϼ�Ȩ�Ѷ������ǣ�');
for i = 1:length(sum_result)
    disp(['���� ', task_dict(i-1), ' ��ƽ�������� ' num2str(sum_result(i))]);
end
disp('�ۺ�������(���׵���)��');
for i = 1:length(sorted_indices)
    disp(['���� ', task_dict(sorted_indices(i)-1)]);
end


%% �����ۺϼ�Ȩ�Ѷȵĺ���
function [sum_result, sorted_indices] = difficulty_weighted_sum(class_accuracies, mean_scores, difficulty_levels, weights)
    % ���ڲ�ͬ�ı������й�һ����Ȼ������Ȩ�ͣ������ʾ��������
    % ��һ������
    class_accuracies = class_accuracies / sum(class_accuracies);
    mean_scores = mean_scores / sum(mean_scores);
    difficulty_levels = difficulty_levels / sum(difficulty_levels);

    % ��һ��Ȩ��
    weights = weights / sum(weights);

    % ��Ȩ���
    sum_result = weights(1) * class_accuracies + weights(2) * mean_scores + weights(3) * difficulty_levels;

    % ���մ�С�����˳����ʾ��������
    [~, sorted_indices] = sort(sum_result);
end
