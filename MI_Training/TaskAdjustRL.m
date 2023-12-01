%% 实时任务调度以及休息时间调整的函数
function [Trials, ChoiceTrial, RestTimeLen] = TaskAdjustRL(scores_trial, ChoiceTrial, Trials, AllTrial, DiffLevels, RestTimeLen)
    
    if AllTrial < 4  % 前4个trial由于无法进行数据采集，所以就先随机挑选
        n_ = length(ChoiceTrial);
        idx = randi(n_);  % 随机挑选的数值
        task_ = ChoiceTrial(1,idx);
        ChoiceTrial(1,idx) = [];  % 选择task_数值，以及在ChoiceTrial里面去掉这个选中的数值
        Trials = [Trials, task_];  % 更新Trials
    else
        % 接下来要写trial数量大于4的情况，要更具相关的scores分数情况来判定
        delta_score = scores_trial(end-2:end) - scores_trial(end-3,end-1);  % 计算出过去3个trial的分数变化
        delta_score(delta_score<=0) = -1;
        delta_score(delta_score>0) = 1;  % 对于delta_score的数值进行映射，映射的结果将方便后面的判断
        
        deltaSum_ = sum(delta_score);
        switch deltaSum_
            case 3
                % 如果此时是不断升高的，那么为了防止疲劳，会适当得调低难度
                currentTask_ = Trials(1, AllTrial);
                if currentTask_ > 0
                    diff_idx = find(DiffLevels, currentTask_);  % 确定当前的难度层级
                else
                    diff_idx = 0;
                end
                % 生成备选的难度
                diff_choice = [];
                if diff_idx > 1
                    diff_choice = [diff_choice, diff_idx-1:-1:1];  % 优先选择降一等级的难度, 其次选择所有低于此难度的数值
                    task_choice = DiffLevels(diff_choice);
                    task_choice = [task_choice, 0];  % 带上休息状态
                else
                    task_choice = [task_choice, 0];  % 带上休息状态
                end
                output_ = find_task_choice(task_choice, DiffLevels, 1);
                task_ = output_(1,1);
                % 休息时长调整
                RestTimeLen = RestTimeLen + 2;

            case 1
                % 如果此时是升高多余降低的，那么还是增加任务难度
                currentTask_ = Trials(1, AllTrial);
                if currentTask_ > 0
                    diff_idx = find(DiffLevels, currentTask_);  % 确定当前的难度层级
                else
                    diff_idx = 0;
                end
                % 生成备选的难度
                diff_choice = [];
                diff_choice = [diff_choice, diff_idx+1:1:length(DiffLevels)];  % 优先选择升高一等级的难度, 其次选择所有低于此难度的数值
                task_choice = DiffLevels(diff_choice);
                output_ = find_task_choice(task_choice, DiffLevels, 0);
                task_ = output_(1,1);
                % 休息时长调整
                RestTimeLen = RestTimeLen - 1;

            case -1
                % 如果此时是降低多余升高的，那么还是增加任务难度
                currentTask_ = Trials(1, AllTrial);
                if currentTask_ > 0
                    diff_idx = find(DiffLevels, currentTask_);  % 确定当前的难度层级
                else
                    diff_idx = 0;
                end
                % 生成备选的难度
                diff_choice = [];
                diff_choice = [diff_choice, diff_idx+1:1:length(DiffLevels)];  % 优先选择升高一等级的难度, 其次选择所有低于此难度的数值
                task_choice = DiffLevels(diff_choice);
                output_ = find_task_choice(task_choice, DiffLevels, 0);
                task_ = output_(1,1);
                % 休息时长调整
                RestTimeLen = RestTimeLen - 1;

            case -3
                % 如果此时是不断降低的，那么为了防止疲劳，会适当得调低难度
                currentTask_ = Trials(1, AllTrial);
                if currentTask_ > 0
                    diff_idx = find(DiffLevels, currentTask_);  % 确定当前的难度层级
                else
                    diff_idx = 0;
                end
                % 生成备选的难度
                diff_choice = [];
                if diff_idx > 1
                    diff_choice = [diff_choice, diff_idx-1:-1:1];  % 优先选择降一等级的难度, 其次选择所有低于此难度的数值
                    task_choice = DiffLevels(diff_choice);
                    task_choice = [task_choice, 0];  % 带上休息状态
                else
                    task_choice = [task_choice, 0];  % 带上休息状态
                end
                output_ = find_task_choice(task_choice, DiffLevels, 1);
                task_ = output_(1,1);
                % 休息时长调整
                RestTimeLen = RestTimeLen + 2;

        end
        % Trials里面添加任务
        Trials = [Trials, task_];
        % 任务集合ChoiceTrial里面删除任务
        index = find(ChoiceTrial == task_, 1);
        if ~isempty(index)
            ChoiceTrial(index) = [];
        end
    end


    % 在DiffLevels中寻找特定任务的函数
    function output = find_task_choice(task_choice, DiffLevels, add_flag)
        output = [];
        for i = 1:length(task_choice)
            if ismember(task_choice(i), DiffLevels)
                output = [output, task_choice(i)];
            end
        end
        if isempty(output)  % 如果找不到合适的任务，直接依据add_flag选择最大或者最小
            if add_flag
                output = [output, min(DiffLevels)];
            else
                output = [output, max(DiffLevels)];
            end
        end
    end
end