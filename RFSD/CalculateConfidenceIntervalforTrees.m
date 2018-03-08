function [accuracy,pruned_tree,optimal_prune,featuremat,classmat] = CalculateConfidenceIntervalforTrees(group1_data,group2_data,datasplit,nreps,subsperfold)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if exist('proximity_sub_limit','var') == 0
    proximity_sub_limit = 200;
end
[nsubs_group1, nvars] = size(group1_data);
nsubs_group2 = size(group2_data,1);
if nsubs_group1 >= nsubs_group2*10
    matchsubs_group1 = nsubs_group2;
    matchsubs_group2 = nsubs_group2;
elseif nsubs_group2 >= nsubs_group1*10
    matchsubs_group2 = nsubs_group1;
    matchsubs_group1 = nsubs_group1;
else
    matchsubs_group1 = nsubs_group1;
    matchsubs_group2 = nsubs_group2;
end
nkfolds = floor(floor(datasplit*(matchsubs_group1+matchsubs_group2))/subsperfold);
accuracy = zeros(3,nreps);
pruned_tree = cell(nreps,1);
%crossval_E = zeros(nreps,1);
%crossval_E_SE = zeros(nreps,1);
%crossval_terminals = zeros(nreps,1);
optimal_prune = zeros(nreps,1);
learning_groups = zeros(floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),1);
testing_groups = zeros(matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + matchsubs_group2 - (floor(matchsubs_group2*datasplit)),1);
learning_groups(1:floor(matchsubs_group1*datasplit),1) = 0;
learning_groups(floor(matchsubs_group1*datasplit)+1:floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),1) = 1;
testing_groups(1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)),1) = 0;
testing_groups(matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + 1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + matchsubs_group2 - (floor(matchsubs_group2*datasplit)),1) = 1;
learning_data = zeros(floor(matchsubs_group1*datasplit) + floor(matchsubs_group2*datasplit),nvars);
testing_data = zeros(matchsubs_group1 - floor(matchsubs_group1*datasplit) + matchsubs_group2 - floor(matchsubs_group2*datasplit),nvars);
classmat = zeros(nreps,nsubs_group1+nsubs_group2);
tic
for i = 1:nreps
    group1_subjects = randperm(nsubs_group1,matchsubs_group1);
    group2_subjects = randperm(nsubs_group2,matchsubs_group2);
    test_group1_subjects = group1_subjects(floor(matchsubs_group1*datasplit)+1:matchsubs_group1);
    test_group2_subjects = group2_subjects(floor(matchsubs_group2*datasplit)+1:matchsubs_group2);
    test_groupall_subjects = test_group1_subjects;
    test_groupall_subjects(end+1:end+max(size(test_group2_subjects))) = test_group2_subjects;
    resample_group1_data = group1_data(group1_subjects,:);
    resample_group2_data = group2_data(group2_subjects,:);
    learning_data(1:floor(matchsubs_group1*datasplit),:) = resample_group1_data(1:floor(matchsubs_group1*datasplit),:);
    learning_data(floor(matchsubs_group1*datasplit)+1:floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),:) = resample_group2_data(1:floor(matchsubs_group2*datasplit),:);
    testing_data(1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)),:) = resample_group1_data(floor(matchsubs_group1*datasplit)+1:matchsubs_group1,:);
    testing_data(matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + 1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + matchsubs_group2 - (floor(matchsubs_group2*datasplit)),:) = resample_group2_data(floor(matchsubs_group2*datasplit)+1:matchsubs_group2,:);
    [accuracy(:,i),pruned_tree{i,1},~,~,~,optimal_prune(i)] = TestTree(learning_groups, learning_data, testing_groups, testing_data,nkfolds);
    [~,~,class_nodes,~] = pruned_tree{i,1}.predict(testing_data);
    for j = 1:size(testing_data,1)
        classmat(i,test_groupall_subjects(j)) = class_nodes(j);
    end
end
toc
featuremat = CollateUsedFeatures(pruned_tree,nvars);
end
