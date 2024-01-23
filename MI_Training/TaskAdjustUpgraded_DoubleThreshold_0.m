%% ����֮ǰ�ı��ֽ��е��������Ѷ�
function [Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded_DoubleThreshold_0(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum)
    % һ��ʼ��ʱ�������޸�����
    if AllTrial < 4  
        MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline;
        Trials = Trials;
        RestTimeLen = RestTimeLenBaseline;
        TrialNum = TrialNum;
    else
        %��ȡ֮ǰ3�������EIָ��ı仯�����΢�ֵ���ʽ��
        delta_score = scores_trial(end-2:end) - scores_trial(end-3:end-1);  
        delta_score(delta_score<=0) = -1;
        delta_score(delta_score>0) = 1;  
         
        deltaSum_ = sum(delta_score);
        switch deltaSum_
            case 3
                
                % �ӳ���Ϣʱ��
                RestTimeLen = RestTimeLenBaseline + 2;
                Trials = Trials;
                TrialNum = TrialNum;
                % ����trials�����뾲Ϣ̬
                %Trials = [Trials(1:AllTrial); 0; Trials(AllTrial+1:end)];
                %TrialNum = TrialNum + 1;
            case 1
                % ������Ϣʱ��
                Trials = Trials;
                RestTimeLen = RestTimeLenBaseline - 1;
                TrialNum = TrialNum;

            case -1
                % ������Ϣʱ��
                Trials = Trials;
                RestTimeLen = RestTimeLenBaseline - 1;
                TrialNum = TrialNum;

            case -3
                
                % ������Ϣʱ��
                Trials = Trials;
                RestTimeLen = RestTimeLenBaseline + 2;
                TrialNum = TrialNum;
        end
        Trigger = Trials(AllTrial);  % ȷ����ǰ�����
        tasks = muSups_trial(2,:);
        task_performance = muSups_trial(1,tasks==Trigger);  % ��ȡͬ��������
        
        if size(task_performance, 1) < 3
            performance_eval = task_performance;  % �������3�εĻ���ֱ����ȡ���е�
        else
            performance_eval = task_performance(1,end-3+1:end);  % ��ȡ֮ǰ3��ʵ��ı��֣�ʹ�������ε�ʵ��������滮��������ʵ���Ѷ�
        end
        % ʹ�û��ڦ�-greedy�ķ�������������Ȩ�صĵ���
        performance_pro = mean(performance_eval(1,:));  % ����ǰ3����ƽ��������Ϊ����ε���ֵ
        task_weights = [0.707,1.0,1.414];
        % ���ڸ��ʽ���ѡ���������MI_MUSup_thre_weight
        if rand() < performance_pro
            % ���ѡ���Ƿ�����Ȩ��
            index = randi(length(task_weights(1,2:end)));
            MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline * task_weights(index+1);
        else
            % ����Ȩ��
            MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline * task_weights(1);
        end
    end
end