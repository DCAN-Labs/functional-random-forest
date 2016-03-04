function [accuracy,treebag,outofbag_error,proxmat,trimmed_feature_sets] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nreps,proximity_sub_limit,varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
rng('shuffle');
if exist('proximity_sub_limit','var') == 0
    proximity_sub_limit = 500;
end
estimate_trees = 0;
weight_forest = 0;
trim_features = 0;
disable_treebag = 0;
holdout = 0;
zform = 0;
permute_data = 0;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        switch(varargin{i})
            case('EstimateTrees')
                estimate_trees = 1;
            case('WeightForest')
                weight_forest = 1;
            case('TrimFeatures')
                trim_features = 1;
                nfeatures = varargin{i+1};
            case('Holdout')
                holdout = 1;
                holdout_data = struct2array(load(varargin{i+1}));
                group_holdout = varargin{i+2};
            case('FisherZ')
                zform = 1;
            case('TreebagsOff')
                disable_treebag = 1;
                treebag = NaN;
            case('Permute')
                permute_data = 1;
        end
    end
end
if holdout == 0
    holdout_data = 0;
end
if (zform)
    group1_data = rtoz(group1_data);
    group2_data = rtoz(group2_data);
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
accuracy = zeros(3,nreps,max(size(holdout_data)));
if disable_treebag == 0
    treebag = cell(nreps,max(size(holdout_data)));
end
proxmat = cell(nreps,max(size(holdout_data)));
outofbag_error = zeros(nreps,ntrees,max(size(holdout_data)));
if (trim_features)
    trimmed_feature_sets = zeros(nreps,nfeatures,max(size(holdout_data)));
    nvars = nfeatures;
end
if holdout == 0
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
        for i = 1:nreps
            all_data = group1_data;
            all_data(end+1:end+nsubs_group2,:) = group2_data;
            group1_subjects = randperm(nsubs_group1,matchsubs_group1);
            group2_subjects = randperm(nsubs_group2,matchsubs_group2);
            resample_group1_data = group1_data(group1_subjects,:);
            resample_group2_data = group2_data(group2_subjects,:);
            if (trim_features)
                [~,~,trimmed_features] = KSFeatureTrimmer(resample_group1_data(1:floor(matchsubs_group1*datasplit),:),resample_group2_data(1:floor(matchsubs_group2*datasplit),:),nfeatures);
                resample_group1_data = group1_data(group1_subjects,trimmed_features);
                resample_group2_data = group2_data(group2_subjects,trimmed_features);
                trimmed_feature_sets(i,:) = trimmed_features;
                all_data = all_data(:,trimmed_features);
            end
            if (permute_data)
                permall_data = resample_group1_data;
                permall_data(size(resample_group1_data,1)+1:size(resample_group1_data,1)+size(resample_group2_data,1),:) = resample_group2_data;
                permall_data_temp = permall_data(randperm(size(resample_group1_data,1)+size(resample_group2_data,1)),:);
                perm1_data = permall_data_temp(1:matchsubs_group1,:);
                perm2_data = permall_data_temp(matchsubs_group1+1:matchsubs_group1+matchsubs_group2,:);
                resample_group1_data = perm1_data;
                resample_group2_data = perm2_data;
                clear permall_data permall_data_temp perm1_data perm2_data
            end
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
                [tree_weights,treebag_temp] = TestTreeBags(learning_groups,learning_data,[],[],ntrees_est,'weight_trees');
                accuracy(:,i) = TestTreeBags([],[], testing_groups, testing_data,ntrees_est,'validation_weighted',treebag_temp,tree_weights);
            else
                if (estimate_trees)
                    [accuracy(:,i),treebag_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation');
                else
                    [accuracy(:,i),treebag_temp,outofbag_error(i,:)] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validationPlusOOB');
                end
            end
            proxmat{i,1} = proximity(treebag_temp.compact,all_data);
            if disable_treebag == 0
                treebag{i,1} = treebag_temp;
            end
            clear treebag_temp
        end
    else
        for i = 1:nreps
            group1_subjects = randperm(nsubs_group1,matchsubs_group1);
            group2_subjects = randperm(nsubs_group2,matchsubs_group2);
            resample_group1_data = group1_data(group1_subjects,:);
            resample_group2_data = group2_data(group2_subjects,:);
            all_data = group1_data(sort(group1_subjects),:);
            all_data(end+1:end+matchsubs_group2,:) = group2_data(sort(group2_subjects),:);            
            if (trim_features)
                [~,~,trimmed_features] = KSFeatureTrimmer(resample_group1_data(1:floor(matchsubs_group1*datasplit),:),resample_group2_data(1:floor(matchsubs_group2*datasplit),:),nfeatures);
                resample_group1_data = group1_data(group1_subjects,trimmed_features);
                resample_group2_data = group2_data(group2_subjects,trimmed_features);
                trimmed_feature_sets(i) = trimmed_features;
            end
            if (permute_data)
                permall_data = resample_group1_data;
                permall_data(size(resample_group1_data,1)+1:size(resample_group1_data,1)+size(resample_group2_data,1),:) = resample_group2_data;
                permall_data_temp = permall_data(randperm(size(resample_group1_data,1)+size(resample_group2_data,1)),:);
                perm1_data = permall_data_temp(1:matchsubs_group1,:);
                perm2_data = permall_data_temp(matchsubs_group1+1:matchsubs_group1+matchsubs_group2,:);
                resample_group1_data = perm1_data;
                resample_group2_data = perm2_data;
                clear permall_data permall_data_temp perm1_data perm2_data
            end
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
                [tree_weights,treebag_temp] = TestTreeBags(learning_groups,learning_data,[],[],ntrees_est,'weight_trees');
                accuracy(:,i) = TestTreeBags([],[], testing_groups, testing_data,ntrees_est,'validation_weighted',treebag_temp,tree_weights);
            else
                if (estimate_trees)
                    [accuracy(:,i),treebag_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation');
                else
                    [accuracy(:,i),treebag_temp,outofbag_error(i,:)] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validationPlusOOB');
                end
            end
            if (trim_features)
                all_data = all_data(:,trimmed_features);
            end
            proxmat{i,1} = proximity(treebag_temp.compact,all_data);
            if disable_treebag == 0
                treebag{i,1} = treebag_temp;
            end
            clear treebag_temp
        end
    end
    toc
else
    for j = 1:max(size(holdout_data))
        data_to_remove = holdout_data(j).ix;
        ncomps_to_remove = max(size(data_to_remove));
        testing_data = zeros(ncomps_to_remove*2,nvars);
        testing_groups = zeros(ncomps_to_remove*2,1);
        testing_groups(1:ncomps_to_remove,1) = 0;
        testing_groups(ncomps_to_remove+1:ncomps_to_remove*2,1) = 1;
        if group_holdout == 1
            index = true(1, size(group1_data, 1));
            index(data_to_remove.') = false;
            group1_data_holdout = group1_data(index, :);
            nsubs_group1_holdout = size(group1_data_holdout,1);
            nsubs_group2_holdout = nsubs_group2;
            group2_data_holdout = group2_data;
            matchsubs_group1_holdout = nsubs_group1_holdout;
            matchsubs_group2_holdout = matchsubs_group2;
            learning_groups = zeros(matchsubs_group1_holdout + matchsubs_group2_holdout - ncomps_to_remove,1);            
            learning_groups(1:matchsubs_group1_holdout,1) = 0;
            learning_groups(matchsubs_group1_holdout+1:matchsubs_group1_holdout + matchsubs_group2_holdout - ncomps_to_remove,1) = 1;
        else
            index = true(1, size(group2_data, 1));
            index(data_to_remove.') = false;
            group2_data_holdout = group2_data(index, :);
            nsubs_group2_holdout = size(group2_data_holdout,1);
            nsubs_group1_holdout = nsubs_group1;
            group1_data_holdout = group1_data; 
            matchsubs_group2_holdout = nsubs_group2_holdout;
            matchsubs_group1_holdout = matchsubs_group1;
            learning_groups = zeros(matchsubs_group1_holdout + matchsubs_group2_holdout - ncomps_to_remove,1);            
            learning_groups(1:matchsubs_group1_holdout-ncomps_to_remove,1) = 0;
            learning_groups(matchsubs_group1_holdout-ncomps_to_remove+1:matchsubs_group1_holdout + matchsubs_group2_holdout - ncomps_to_remove,1) = 1;
        end
        learning_data = zeros(matchsubs_group1_holdout + matchsubs_group2_holdout - ncomps_to_remove,nvars);
        tic
        if nsubs_group1_holdout + nsubs_group2_holdout <= proximity_sub_limit
            all_data = group1_data;
            all_data(end+1:end+nsubs_group2_holdout,:) = group2_data;
            for i = 1:nreps
                group1_subjects = randperm(nsubs_group1_holdout,matchsubs_group1_holdout);
                group2_subjects = randperm(nsubs_group2_holdout,matchsubs_group2_holdout);
                resample_group1_data = group1_data_holdout(group1_subjects,:);
                resample_group2_data = group2_data_holdout(group2_subjects,:);
                if (trim_features)
                    [~,~,trimmed_features] = KSFeatureTrimmer(resample_group1_data(1:floor(matchsubs_group1_holdout*datasplit),:),resample_group2_data(1:floor(matchsubs_group2_holdout*datasplit),:),nfeatures);
                    resample_group1_data = group1_data_holdout(group1_subjects,trimmed_features);
                    resample_group2_data = group2_data_holdout(group2_subjects,trimmed_features);
                    trimmed_feature_sets(i,:,j) = trimmed_features;
                    all_data = all_data(:,trimmed_features);
                else
                    trimmed_features = 1:nvars;
                end
                if (permute_data)
                    permall_data = resample_group1_data;
                    permall_data(size(resample_group1_data,1)+1:size(resample_group1_data,1)+size(resample_group2_data,1),:) = resample_group2_data;
                    permall_data_temp = permall_data(randperm(size(resample_group1_data,1)+size(resample_group2_data,1)),:);                    
                    perm1_data = permall_data_temp(1:matchsubs_group1_holdout,:);
                    perm2_data = permall_data_temp(matchsubs_group1_holdout+1:matchsubs_group1_holdout+matchsubs_group2_holdout,:);
                    resample_group1_data = perm1_data;
                    resample_group2_data = perm2_data;
                    clear perm1_data perm2_data permall_data permall_data_temp
                end
                if group_holdout == 1
                    learning_data(1:matchsubs_group1_holdout,:) = resample_group1_data;
                    learning_data(matchsubs_group1_holdout+1:matchsubs_group1_holdout+matchsubs_group2_holdout - ncomps_to_remove,:) = resample_group2_data(1:matchsubs_group2_holdout - ncomps_to_remove,:);
                    testing_data(1:ncomps_to_remove,:) = group1_data(data_to_remove,trimmed_features);
                    testing_data(ncomps_to_remove+1:ncomps_to_remove*2,:) = resample_group2_data(matchsubs_group2_holdout-ncomps_to_remove+1:matchsubs_group2_holdout,:);
                else
                    learning_data(1:matchsubs_group1_holdout-ncomps_to_remove,:) = resample_group1_data(matchsubs_group1_holdout - ncomps_to_remove,:);
                    learning_data(matchsubs_group1_holdout-ncomps_to_remove+1:matchsubs_group1_holdout+matchsubs_group2_holdout - ncomps_to_remove,:) = resample_group2_data;
                    testing_data(1:ncomps_to_remove,:) = resample_group1_data(matchsubs_group1_holdout-ncomps_to_remove+1:matchsubs_group1_holdout,:);
                    testing_data(ncomps_to_remove+1:ncomps_to_remove*2,:) = group2_data(data_to_remove,trimmed_features);
                end
                if (estimate_trees)
                    ntrees_est = TestTreeBags(learning_groups,learning_data,[],[],ntrees,'estimate_trees');
                else
                    ntrees_est = ntrees;
                end
                if (weight_forest)
                    [tree_weights,treebag_temp] = TestTreeBags(learning_groups,learning_data,[],[],ntrees_est,'weight_trees');
                    accuracy(:,i,j) = TestTreeBags([],[], testing_groups, testing_data,ntrees_est,'validation_weighted',treebag_temp,tree_weights);
                else
                    if (estimate_trees)
                        [accuracy(:,i,j),treebag_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation');
                    else
                        [accuracy(:,i,j),treebag_temp,outofbag_error(i,:,j)] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validationPlusOOB');
                    end
                end
                proxmat{i,j} = proximity(treebag_temp.compact,all_data);
                if disable_treebag == 0
                    treebag{i,1,j} = treebag_temp;
                end
                clear treebag_temp
            end
        else
            for i = 1:nreps
                group1_subjects = randperm(nsubs_group1_holdout,matchsubs_group1_holdout);
                group2_subjects = randperm(nsubs_group2_holdout,matchsubs_group2_holdout);
                resample_group1_data = group1_data_holdout(group1_subjects,:);
                resample_group2_data = group2_data_holdout(group2_subjects,:);
                if (trim_features)
                    [~,~,trimmed_features] = KSFeatureTrimmer(resample_group1_data(1:floor(matchsubs_group1_holdout*datasplit),:),resample_group2_data(1:floor(matchsubs_group2_holdout*datasplit),:),nfeatures);
                    resample_group1_data = group1_data_holdout(group1_subjects,trimmed_features);
                    resample_group2_data = group2_data_holdout(group2_subjects,trimmed_features);
                    trimmed_feature_sets(i,:,j) = trimmed_features;
                else
                    trimmed_features = 1:nvars;
                end
                if (permute_data)
                    permall_data = resample_group1_data;
                    permall_data(size(resample_group1_data,1)+1:size(resample_group1_data,1)+size(resample_group2_data,1),:) = resample_group2_data;
                    permall_data_temp = permall_data(randperm(size(resample_group1_data,1)+size(resample_group2_data,1)),:);                    
                    perm1_data = permall_data_temp(1:matchsubs_group1_holdout,:);
                    perm2_data = permall_data_temp(matchsubs_group1_holdout+1:matchsubs_group1_holdout+matchsubs_group2_holdout,:);
                    resample_group1_data = perm1_data;
                    resample_group2_data = perm2_data;
                    clear perm1_data perm2_data permall_data permall_data_temp
                end
                if group_holdout == 1
                    all_data = group1_data(sort([group1_subjects data_to_remove]),trimmed_features); 
                    all_data(end+1:end+matchsubs_group2_holdout,:) = group2_data(sort(group2_subjects),trimmed_features); 
                    learning_data(1:matchsubs_group1_holdout,:) = resample_group1_data;
                    learning_data(matchsubs_group1_holdout+1:matchsubs_group1_holdout+matchsubs_group2_holdout - ncomps_to_remove,:) = resample_group2_data(1:matchsubs_group2_holdout - ncomps_to_remove,:);
                    testing_data(1:ncomps_to_remove,:) = group1_data(data_to_remove,trimmed_features);
                    testing_data(ncomps_to_remove+1:ncomps_to_remove*2,:) = resample_group2_data(matchsubs_group2_holdout-ncomps_to_remove+1:matchsubs_group2_holdout+ncomps_to_remove,:);
                else
                    all_data = group1_data(sort(group1_subjects),trimmed_features); 
                    all_data(end+1:end+matchsubs_group2_holdout+ncomps_to_remove,:) = group2_data(sort([group2_subjects data_to_remove]),trimmed_features);                     
                    learning_data(1:matchsubs_group1_holdout-ncomps_to_remove,:) = resample_group1_data(matchsubs_group1_holdout - ncomps_to_remove,:);
                    learning_data(matchsubs_group1_holdout-ncomps_to_remove+1:matchsubs_group1_holdout+matchsubs_group2_holdout - ncomps_to_remove,:) = resample_group2_data;
                    testing_data(1:ncomps_to_remove,:) = resample_group1_data(matchsubs_group1_holdout-ncomps_to_remove+1:matchsubs_group1_holdout+ncomps_to_remove,:);
                    testing_data(ncomps_to_remove+1:ncomps_to_remove*2,:) = group2_data(data_to_remove,trimmed_features);
                end
                if (estimate_trees)
                    ntrees_est = TestTreeBags(learning_groups,learning_data,[],[],ntrees,'estimate_trees');
                else
                    ntrees_est = ntrees;
                end
                if (weight_forest)
                    [tree_weights,treebag_temp] = TestTreeBags(learning_groups,learning_data,[],[],ntrees_est,'weight_trees');
                    accuracy(:,i,j) = TestTreeBags([],[], testing_groups, testing_data,ntrees_est,'validation_weighted',treebag_temp,tree_weights);
                else
                    if (estimate_trees)
                        [accuracy(:,i,j),treebag_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation');
                    else
                        [accuracy(:,i,j),treebag_temp,outofbag_error(i,:,j)] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validationPlusOOB');
                    end
                end
                if (trim_features)
                    all_data = all_data(:,trimmed_features);
                end
                proxmat{i,j} = proximity(treebag_temp.compact,all_data);
                if disable_treebag == 0
                    treebag{i,1,j} = treebag_temp;
                end
                clear treebag_temp
            end
        end
        toc    
    end
end
end