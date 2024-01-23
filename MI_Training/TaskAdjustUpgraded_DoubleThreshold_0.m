%% 根据之前的表现进行调整任务难度
function [Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded_DoubleThreshold_0(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum)
    % 一开始暂时不进行修改任务
    if AllTrial < 4  
        MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline;
        Trials = Trials;
        RestTimeLen = RestTimeLenBaseline;
        TrialNum = TrialNum;
    else
        %提取之前3个任务的EI指标的变化情况（微分的形式）
        delta_score = scores_trial(end-2:end) - scores_trial(end-3:end-1);  
        delta_score(delta_score<=0) = -1;
        delta_score(delta_score>0) = 1;  
         
        deltaSum_ = sum(delta_score);
        switch deltaSum_
            case 3
                
                % 延长休息时间
                RestTimeLen = RestTimeLenBaseline + 2;
                Trials = Trials;
                TrialNum = TrialNum;
                % 调整trials，加入静息态
                %Trials = [Trials(1:AllTrial); 0; Trials(AllTrial+1:end)];
                %TrialNum = TrialNum + 1;
            case 1
                % 减少休息时间
                Trials = Trials;
                RestTimeLen = RestTimeLenBaseline - 1;
                TrialNum = TrialNum;

            case -1
                % 减少休息时间
                Trials = Trials;
                RestTimeLen = RestTimeLenBaseline - 1;
                TrialNum = TrialNum;

            case -3
                
                % 减少休息时间
                Trials = Trials;
                RestTimeLen = RestTimeLenBaseline + 2;
                TrialNum = TrialNum;
        end
        Trigger = Trials(AllTrial);  % 确定当前的类别
        tasks = muSups_trial(2,:);
        task_performance = muSups_trial(1,tasks==Trigger);  % 提取同类别的数据
        
        if size(task_performance, 1) < 3
            performance_eval = task_performance;  % 如果不满3次的话，直接提取所有的
        else
            performance_eval = task_performance(1,end-3+1:end);  % 提取之前3次实验的表现，使用这三次的实验表现来规划接下来的实验难度
        end
        % 使用基于ξ-greedy的方法来进行任务权重的调整
        performance_pro = mean(performance_eval(1,:));  % 计算前3个的平均概率作为这个ξ的数值
        task_weights = [0.707,1.0,1.414];
        % 基于概率进行选择接下来的MI_MUSup_thre_weight
        if rand() < performance_pro
            % 随机选择是否增加权重
            index = randi(length(task_weights(1,2:end)));
            MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline * task_weights(index+1);
        else
            % 降低权重
            MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline * task_weights(1);
        end
    end
end