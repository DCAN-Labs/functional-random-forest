function [ntrees] = EstimateNumberOfTreesCI(group1_data,group2_data,initial_ntrees,nrepsCI)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
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
outofbag_error = zeros(nrepsCI,initial_ntrees);
learning_groups = zeros(floor(matchsubs_group1)+floor(matchsubs_group2),1);
learning_groups(1:floor(matchsubs_group1),1) = 0;
learning_groups(floor(matchsubs_group1)+1:floor(matchsubs_group1)+floor(matchsubs_group2),1) = 1;
learning_data = zeros(floor(matchsubs_group1) + floor(matchsubs_group2),nvars);
tic
for i = 1:nrepsCI
    group1_subjects = randperm(nsubs_group1,matchsubs_group1);
    group2_subjects = randperm(nsubs_group2,matchsubs_group2);
    resample_group1_data = group1_data(group1_subjects,:);
    resample_group2_data = group2_data(group2_subjects,:);
    learning_data(1:floor(matchsubs_group1),:) = resample_group1_data(1:floor(matchsubs_group1),:);
    learning_data(floor(matchsubs_group1)+1:floor(matchsubs_group1)+floor(matchsubs_group2),:) = resample_group2_data(1:floor(matchsubs_group2),:);
    [~,~,outofbag_error(i,:)] = TestTreeBags(learning_groups, learning_data, [],[],initial_ntrees);
end
toc
mean_outofbag_error = mean(outofbag_error,1);
min_points = find(mean_outofbag_error == min(mean_outofbag_error));
ntrees = min_points(end);
end

