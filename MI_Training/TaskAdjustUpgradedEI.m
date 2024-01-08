%% 实时任务调度以及休息时间调整的函�?
function [Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgradedEI(scores_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum)
    
    if AllTrial < 4  % �?4个trial由于无法进行数据采集，所以就先随机挑�?
        MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline;
        Trials = Trials;
        RestTimeLen = RestTimeLenBaseline;
        TrialNum = TrialNum;
    else
        % 接下来要写trial数量大于4的情况，要更具相关的scores分数情况来判�?
        delta_score = scores_trial(end-2:end) - scores_trial(end-3:end-1);  % 计算出过�?3个trial的分数变�?
        delta_score(delta_score<=0) = -1;
        delta_score(delta_score>0) = 1;  % 对于delta_score的数值进行映射，映射的结果将方便后面的判�?
         
        deltaSum_ = sum(delta_score);
        switch deltaSum_
            case 3
                % 如果此时是不断升高的，那么为了防止疲劳，会�?�当得调低难度，调整mu的追踪数�?
                MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline * 0.707;
                % 休息时长调整
                RestTimeLen = RestTimeLenBaseline + 2;
                % 加入静息任务，作为休�?
                Trials = [Trials(1:AllTrial); 0; Trials(AllTrial+1:end)];
                TrialNum = TrialNum + 1;
            case 1
                % 如果此时是升高多余降低的，那么还是增加任务难�?
                MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline * 1.414;
                % 休息时长调整
                Trials = Trials;
                RestTimeLen = RestTimeLenBaseline - 1;
                TrialNum = TrialNum;

            case -1
                % 如果此时是降低多余升高的，那么还是增加任务难�?
                MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline * 1.414;
                % 休息时长调整
                Trials = Trials;
                RestTimeLen = RestTimeLenBaseline - 1;
                TrialNum = TrialNum;

            case -3
                % 如果此时是不断降低的，那么为了防止疲劳，会�?�当得调低难�?
                MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline * 0.707;
                % 休息时长调整
                Trials = Trials;
                RestTimeLen = RestTimeLenBaseline + 2;
                TrialNum = TrialNum;
        end
    end
end