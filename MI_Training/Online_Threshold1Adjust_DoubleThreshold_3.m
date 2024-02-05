%% 在线自适应调整阈值2
function score_thre1 = Online_Threshold1Adjust_DoubleThreshold_3(scores, score_thre1, score_thre, mode)
    if length(scores) > 2
       scores_v = scores(2:end) - scores(1:end-1);
       if mode == 'PNG'
            if scores_v(end) > 0
                score_thre1 = score_thre1 + 0.1 * scores_v(end);
            else
               score_thre1 = score_thre1 + 0.75 * scores_v(end);
            end
       end
       if mode == 'Game'
            if scores_v(end) > 0
                positive_scores_v = scores_v(scores_v>0);
                score_thre1 = scores(end-1) + quantile(positive_scores_v,0.75);
                %score_thre1 = scores(end-1) + max(positive_scores_v);
                disp(['score_thre1: ', num2str(score_thre1)]);
            else
                score_thre1 = score_thre1 + 0.75 * scores_v(end);
            end
       end

       if score_thre1 < score_thre
           score_thre1 = 0.7 * score_thre;
       end
   end
end