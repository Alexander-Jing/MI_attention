%% 实时任务调度以及休息时间调整的函数
function [Trials, MI_MUSup_thre_weight, RestTimeLen] = TaskAdjustUpgraded(scores_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline)
    
    if AllTrial < 4  % 前4个trial由于无法进行数据采集，所以就先随机挑选
        MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline;
    else
        % 接下来要写trial数量大于4的情况，要更具相关的scores分数情况来判定
        delta_score = scores_trial(end-2:end) - scores_trial(end-3,end-1);  % 计算出过去3个trial的分数变化
        delta_score(delta_score<=0) = -1;
        delta_score(delta_score>0) = 1;  % 对于delta_score的数值进行映射，映射的结果将方便后面的判断
         
        deltaSum_ = sum(delta_score);
        switch deltaSum_
            case 3
                % 如果此时是不断升高的，那么为了防止疲劳，会适当得调低难度，调整mu的追踪数值
                MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline * 0.707;
                % 休息时长调整
                RestTimeLen = RestTimeLenBaseline + 2;
                % 加入静息任务，作为休息
                Trials = [Trials(1:AllTrial), 0, Trials(AllTrial+1:end)];
            case 1
                % 如果此时是升高多余降低的，那么还是增加任务难度
                MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline * 1.414;
                % 休息时长调整
                RestTimeLen = RestTimeLenBaseline - 1;

            case -1
                % 如果此时是降低多余升高的，那么还是增加任务难度
                MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline * 1.414;
                % 休息时长调整
                RestTimeLen = RestTimeLenBaseline - 1;

            case -3
                % 如果此时是不断降低的，那么为了防止疲劳，会适当得调低难度
                MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline * 0.707;
                % 休息时长调整
                RestTimeLen = RestTimeLenBaseline + 2;
        end
    end
end