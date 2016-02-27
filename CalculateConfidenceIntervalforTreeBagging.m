function [accuracy,treebag,outofbag_error,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nreps,proximity_sub_limit,varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if exist('proximity_sub_limit','var') == 0
    proximity_sub_limit = 200;
end
estimate_trees = 0;
weight_forest = 0;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        switch(varargin{i})
            case('EstimateTrees')
                estimate_trees = 1;
            case('WeightForest')
                weight_forest = 1;
        end
    end
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
accuracy = zeros(3,nreps);
treebag = cell(nreps,1);
proxmat = cell(nreps,1);
outofbag_error = zeros(nreps,ntrees);
learning_groups = zeros(floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),1);
testing_groups = zeros(matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + matchsubs_group2 - (floor(matchsubs_group2*datasplit)),1);
learning_groups(1:floor(matchsubs_group1*datasplit),1) = 0;
learning_groups(floor(matchsubs_group1*datasplit)+1:floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),1) = 1;
testing_groups(1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)),1) = 0;
testing_groups(matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + 1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + matchsubs_group2 - (floor(matchsubs_group2*datasplit)),1) = 1;
learning_data = zeros(floor(matchsubs_group1*datasplit) + floor(matchsubs_group2*datasplit),nvars);
testing_data = zeros(matchsubs_group1 - floor(matchsubs_group1*datasplit) + matchsubs_group2 - floor(matchsubs_group2*datasplit),nvars);
tic
if nsubs_group1 + nsubs_group2 <= proximity_sub_limit
    all_data = group1_data;
    all_data(end+1:end+nsubs_group2,:) = group2_data;
    for i = 1:nreps
        group1_subjects = randperm(nsubs_group1,matchsubs_group1);
        group2_subjects = randperm(nsubs_group2,matchsubs_group2);
        resample_group1_data = group1_data(group1_subjects,:);
        resample_group2_data = group2_data(group2_subjects,:);
        learning_data(1:floor(matchsubs_group1*datasplit),:) = resample_group1_data(1:floor(matchsubs_group1*datasplit),:);
        learning_data(floor(matchsubs_group1*datasplit)+1:floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),:) = resample_group2_data(1:floor(matchsubs_group2*datasplit),:);
        testing_data(1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)),:) = resample_group1_data(floor(matchsubs_group1*datasplit)+1:matchsubs_group1,:);
        testing_data(matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + 1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + matchsubs_group2 - (floor(matchsubs_group2*datasplit)),:) = resample_group2_data(floor(matchsubs_group2*datasplit)+1:matchsubs_group2,:);
        if (estimate_trees)
            ntrees_est = TestTreeBags(learning_groups,learning_data,[],[],ntrees,'estimate_trees');
        else
            ntrees_est = ntrees;
        end
        if (weight_forest)
            [tree_weights,treebag{i,1}] = TestTreeBags(learning_groups,learning_data,[],[],ntrees_est,'weight_trees');
            accuracy(:,i) = TestTreeBags([],[], testing_groups, testing_data,ntrees_est,'validation_weighted',treebag{i,1},tree_weights);
        else
            if (estimate_trees)
                [accuracy(:,i),treebag{i,1}] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation');
            else
                [accuracy(:,i),treebag{i,1},outofbag_error(i,:)] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validationPlusOOB');
            end
        end
        proxmat{i,1} = proximity(treebag{i,1}.compact,all_data);
    end
else
    for i = 1:nreps
        group1_subjects = randperm(nsubs_group1,matchsubs_group1);
        group2_subjects = randperm(nsubs_group2,matchsubs_group2);
        resample_group1_data = group1_data(group1_subjects,:);
        resample_group2_data = group2_data(group2_subjects,:);
        learning_data(1:floor(matchsubs_group1*datasplit),:) = resample_group1_data(1:floor(matchsubs_group1*datasplit),:);
        learning_data(floor(matchsubs_group1*datasplit)+1:floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),:) = resample_group2_data(1:floor(matchsubs_group2*datasplit),:);
        testing_data(1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)),:) = resample_group1_data(floor(matchsubs_group1*datasplit)+1:matchsubs_group1,:);
        testing_data(matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + 1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + matchsubs_group2 - (floor(matchsubs_group2*datasplit)),:) = resample_group2_data(floor(matchsubs_group2*datasplit)+1:matchsubs_group2,:);
        if (estimate_trees)
            ntrees_est = TestTreeBags(learning_groups,learning_data,[],[],ntrees,'estimate_trees');
        else
            ntrees_est = ntrees;
        end
        if (weight_forest)
            [tree_weights,treebag{i,1}] = TestTreeBags(learning_groups,learning_data,[],[],ntrees_est,'weight_trees');
            accuracy(:,i) = TestTreeBags([],[], testing_groups, testing_data,ntrees_est,'validation_weighted',treebag{i,1},tree_weights);
        else
            if (estimate_trees)
                [accuracy(:,i),treebag{i,1}] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation');
            else
                [accuracy(:,i),treebag{i,1},outofbag_error(i,:)] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validationPlusOOB');
            end
        end
        all_data = learning_data;
        all_data(end+1:end+size(testing_data,1),:) = testing_data;
        proxmat{i,1} = proximity(treebag{i,1}.compact,all_data);
    end
end
toc
end
