function [accuracy,permute_accuracy,pruned_tree,optimal_prune,featuremat,classmat,group1_data,group2_data] = SimulateTwoBiGroupTree(group1_subjectsize,group2_subjectsize,splittype,effsizevars,datasplit,nrepsCI,nrepsPM,filename,subsperfold)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if exist('subsperfold','var') == 0
    subsperfold = floor((group1_subjectsize+group2_subjectsize)/10);
end
if exist('filename','var') == 0
    filename = [];
end
switch(splittype)
    case('split')
        [group1_data, group2_data] = SimulateTwoBiGroupDataSplitVar(group1_subjectsize,group2_subjectsize,effsizevars{1},effsizevars{2},effsizevars{3},effsizevars{4},effsizevars{5});
    case('double')
        [group1_data, group2_data] = SimulateTwoBiGroupDataByDoubling(group1_subjectsize,group2_subjectsize,effsizevars{1},effsizevars{2},effsizevars{3});
    case('sign')
        [group1_data, group2_data] = SimulateTwoBiGroupDataBySign(group1_subjectsize,group2_subjectsize,effsizevars{1},effsizevars{2},effsizevars{3});
end
[accuracy,pruned_tree,optimal_prune,featuremat,classmat] = CalculateConfidenceIntervalforTrees(group1_data,group2_data,datasplit,nrepsCI,subsperfold);

all_data = zeros(group1_subjectsize+group2_subjectsize,size(group1_data,2));
all_data(1:group1_subjectsize,:) = group1_data;
all_data(group1_subjectsize+1:group1_subjectsize+group2_subjectsize,:) = group2_data;
permute_accuracy = zeros(3,nrepsCI,nrepsPM);
tic
for i = 1:nrepsPM
    permall_data = all_data(randperm(group1_subjectsize+group2_subjectsize),:);
    perm1_data = permall_data(1:group1_subjectsize,:);
    perm2_data = permall_data(group1_subjectsize+1:group1_subjectsize+group2_subjectsize,:);
    permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTrees(perm1_data,perm2_data,datasplit,nrepsCI,subsperfold);
end
toc
tic
if isempty(filename) == 0
    save(strcat(filename,'.mat'),'accuracy','permute_accuracy','pruned_tree','optimal_prune','featuremat','classmat','group1_data','group2_data','-v7.3');
end
toc
end
