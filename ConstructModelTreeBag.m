function [accuracy,permute_accuracy,treebag,proxmat] = ConstructModelTreeBag(group1_data,group2_data,datasplit,nrepsCI,ntrees,nrepsPM,filename,varargin)
%ConstructModelTreeBag generates a model comprising ensembles of trees and 
%examines the accuracy on data left out of the sample. One can select a
%number of permutations to generate permuted accuracy under the assumptions
%of the null hypothesis (e.g. sets of null distributions of accuracy).
%%%%INPUTS:%%%%%
%       group1_data -- A NxM two-dimensional matrix where N represents the
%       subjects and M respresents the variables (e.g. features). The
%       matrix can be a cell matrix if one has categorical variables.
%       group2_data -- A NxM two-dimensional matrix where N represents the
%       subjects and M respresents the variables (e.g. features). The
%       matrix can be a cell matrix if one has categorical variables.
%       datasplit -- a positive value greater than 0 and less than 1 that indicates
%       the number of subjects to isolate as test cases. This fraction is
%       calculated per group, so the same number of subjects will be selected
%       per group.
%       nrepsCI -- a whole number that indicates the number of repetitions
%       for calculating accuracy confidence intervals.
%       ntrees -- a whole number that indicates the maximum number of trees
%       that the algorithm will use. Please note that not all forests will
%       have the same number of trees. 
%       nrepsPM -- a whole number that indicates the number of null
%       distribution sets to generate. Setting this value to 0 will disable
%       the permutations.
%       filename -- the prefix for a .mat file that will store the outputs
%       (see below).
%%%%OPTIONAL INPUTS%%%%
%   Each optional input is a string separated by a comma, below are
%   currently available options:
%       'EstimateTree' -- this setting will turn on tree estimation to
%       reduce CPU/RAM usage. When on, the number of trees will be
%       estimated via out of bag error estimation. The final model will
%       then include all training data. If off, the final model will
%       provide out of bag error estimates, but only 2/3 of all data will be used.
%       'WeightForest' -- this setting will turn on weight estimation of the final model using
%       in-sample estimates of accuracy per tree. Weight estimation is the
%       final step before making predictions from the full model.
%
%%%%OUTPUTS:%%%%%
%       accuracy -- a G+1xNrepsCI matrix of accuracy where each row is a
%       group and each column is a random forest. The first row represents
%       the mean accuracy across all groups.
%       permute_accuracy -- a G+1xNrepsCIxNrepsPM matrix of accuracy under
%       the null distribution. Each sheet represents a different
%       permutation of the underlying data.
%       treebag -- a cell matrix containing NrepsCI TreeBagger objects
%       proxmat -- a cell matrix with NrepsCI cells where each cell
%       contains a NxN double matrix, where N represents the number of
%       subjects. If the number of subjects is too large, each cell will
%       contain a sample of the total number.
%       outofbag_error -- a NrepsCIxntrees matrix that represents the out
%       of bag error.
%%%%USAGE:%%%%%
% [accuracy,permute_accuracy,treebag,proxmat,outofbag_error] = ConstructModelTreeBag(group1_data,group2_data,datasplit,nrepsCI,ntrees,nrepsPM,filename,*'EstimateTree'*,'*WeightForest*')
%
%
%See also: TestTreeBags
weight_forest = 0;
estimate_trees = 0;
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
nsubs_group1 = size(group1_data,1);
nsubs_group2 = size(group2_data,1);
if (weight_forest)
    if (estimate_trees)
        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,200,'WeightForest','EstimateTrees');
    else
        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,200,'WeightForest');
    end
else
    if (estimate_trees)
        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,200,'EstimateTrees');
    else
        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,200);
    end   
end
if nrepsPM > 0
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
    permute_accuracy = zeros(3,nrepsCI,nrepsPM);
    tic
    for i = 1:nrepsPM
        group1_subjects = randperm(nsubs_group1,matchsubs_group1);
        group2_subjects = randperm(nsubs_group2,matchsubs_group2);
        all_data = group1_data(group1_subjects,:);
        all_data(end+1:end+matchsubs_group2,:) = group2_data(group2_subjects,:);
        permall_data = all_data(randperm(matchsubs_group1+matchsubs_group2),:);
        perm1_data = permall_data(1:matchsubs_group1,:);
        perm2_data = permall_data(matchsubs_group1+1:matchsubs_group1+matchsubs_group2,:);
        if (weight_forest)
            if (estimate_trees)
                permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(perm1_data,perm2_data,datasplit,ntrees,nrepsCI,200,'WeightForest','EstimateTrees');
            else
                permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(perm1_data,perm2_data,datasplit,ntrees,nrepsCI,200,'WeightForest');
            end
        else
            if (estimate_trees)
                permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(perm1_data,perm2_data,datasplit,ntrees,nrepsCI,200,'EstimateTrees');
            else
                permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(perm1_data,perm2_data,datasplit,ntrees,nrepsCI,200);
            end   
        end
    end
    toc
else
    permute_accuracy = NaN;
end
tic
save(strcat(filename,'.mat'),'accuracy','permute_accuracy','treebag','proxmat','outofbag_error','-v7.3');
toc
end

