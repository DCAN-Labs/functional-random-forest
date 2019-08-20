function [accuracy,permute_accuracy,treebag,outofbag_error,] = SimulateTwoGroupTree(group1_subjectsize,group2_subjectsize,effsize,datasplit,nrepsCI,nrepsPM)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[group1_data, group2_data] = SimulateTwoGroupData(group1_subjectsize,group2_subjectsize,effsize);
[accuracy,pruned_tree,optimal_prune,featuremat,classmat] = CalculateConfidenceIntervalforTrees(group1_data,group2_data,datasplit,nrepsCI);
all_data = zeros(group1_subjectsize+group2_subjectsize,size(effsize,1));
all_data(1:group1_subjectsize,:) = group1_data;
all_data(group1_subjectsize+1:group1_subjectsize+group2_subjectsize,:) = group2_data;
permute_accuracy = zeros(3,nrepsCI,nrepsPM);
tic
for i = 1:nrepsPM
    permall_data = all_data(randperm(group1_subjectsize+group2_subjectsize),:);
    perm1_data = permall_data(1:group1_subjectsize,:);
    perm2_data = permall_data(group1_subjectsize+1:group1_subjectsize+group2_subjectsize,:);
    permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTrees(perm1_data,perm2_data,datasplit,nrepsCI);
end
toc
end

