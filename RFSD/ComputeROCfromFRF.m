function [FRFAUC,tested_outcomes,tested_predictions,tested_scores,allpredict] = ComputeROCfromFRF(group1predict,group2predict,group1scores,group2scores,final_outcomes,filename)
%ComputeROCfromFRF calculates the roc curve for the FRF multiclass
%prediction. Requires the outputs from ConstructModelTreeBag to run.
%Outputs from visualization are not required.
%

%recombine predictions to acocunt for backwards compatibility options

if isempty(group2predict)
    allpredict = round(group1predict);    
else
    allpredict = round([group1predict;group2predict]);
end
if isempty(group2scores)
    allscores = group1scores;   
else
    allscores = [group1scores;group2scores];
end
%identify and select tested subjects to compute the roc
tested_subjects = isnan(allpredict) == 0;
categorical_outcomes = unique(allpredict(tested_subjects));
tested_outcomes = final_outcomes(tested_subjects);
tested_predictions = allpredict(tested_subjects);
tested_scores = allscores(tested_subjects,:);
%declare reformatted variables that interface with the roc function
sparse_outcomes = zeros(length(tested_predictions),length(categorical_outcomes));
sparse_predictions = zeros(length(tested_predictions),length(categorical_outcomes));
for currcase = 1:length(sparse_outcomes)
    sparse_outcomes(currcase,tested_outcomes(currcase)) = 1;
    sparse_predictions(currcase,tested_predictions(currcase)) = 1;
end
%calculate true and false positive rates
[tpr_WTA,fpr_WTA] = roc(sparse_outcomes',sparse_predictions');
[tpr_SCORE,fpr_SCORE] = roc(sparse_outcomes',tested_scores');
FRFAUC = zeros(length(categorical_outcomes),2);
%compute AUCs per class. Do so for both WTA and SCORE approaches.
for iter = 1:length(categorical_outcomes)
    FRFAUC(iter,1) = trapz([fpr_WTA{iter} 1], [tpr_WTA{iter} 1]);
    FRFAUC(iter,2) = trapz(fpr_SCORE{iter},tpr_SCORE{iter});
end
%construct and plot ROC curves, save them to files.
h = plotroc(sparse_outcomes',sparse_predictions');
saveas(h,[filename '_ROC_WTA.tif'],'tif');
h2 = plotroc(sparse_outcomes',tested_scores');
saveas(h2,[filename '_ROC_SCORES.tif'],'tif');
close all
end

