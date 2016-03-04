function [accuracy,permute_accuracy,treebag,proxmat,trimmed_features] = ConstructModelTreeBag(group1_data,group2_data,datasplit,nrepsCI,ntrees,nrepsPM,filename,varargin)
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
if isstruct(group1_data)
    group1_data = struct2array(load(group1_data.path,group1_data.variable));
end
if isstruct(group2_data)
    group2_data = struct2array(load(group2_data.path,group2_data.variable));
end
weight_forest = 0;
estimate_trees = 0;
trim_features = 0;
holdout = 0;
zform = 0;
disable_treebag = 0;
proximity_sub_limit = 500;
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
                holdout_data = varargin{i+1};
                group_holdout = varargin{i+2};
            case('FisherZ')
                zform = 1;
            case('TreebagsOff')
                disable_treebag = 1;
                treebag = NaN;
            case('ProximitySubLimit')
                proximity_sub_limit = varargin{i+1};
        end
    end
end
if (weight_forest)
    if (estimate_trees)
        if (trim_features)
            if (holdout)
                if (zform)
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff');
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'FisherZ');    
                    end
                else
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'TreebagsOff');
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','TrimFeatures',nfeatures,'Holdout',holdout_data);
                    end
                end
            else
                if (zform)
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','TrimFeatures',nfeatures,'FisherZ','TreebagsOff');
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','TrimFeatures',nfeatures,'FisherZ');                        
                    end
                else
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','TrimFeatures',nfeatures,'TreebagsOff');    
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','TrimFeatures',nfeatures);                            
                    end
                end
            end
        else
            if (holdout)
                if (zform)
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff');
                    else
                        trimmed_features = NaN;
                        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','Holdout',holdout_data,group_holdout,'FisherZ');                        
                    end
                else
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','Holdout',holdout_data,group_holdout,'TreebagsOff');
                    else
                        trimmed_features = NaN;
                        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','Holdout',holdout_data);                        
                    end
                end
            else
                if (zform)
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','FisherZ','TreebagsOff');
                    else
                        trimmed_features = NaN;
                        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','FisherZ');                        
                    end
                else
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','TreebagsOff');
                    else
                        trimmed_features = NaN;
                        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees');                        
                    end
                end
            end
        end
    else
        if (trim_features)
            if (holdout)
                if (zform)
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff');  
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'FisherZ');                          
                    end
                else
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'TreebagsOff');     
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','TrimFeatures',nfeatures,'Holdout',holdout_data);                         
                    end
                end
            else
                if (zform)
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','TrimFeatures',nfeatures,'FisherZ','TreebagsOff');     
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','TrimFeatures',nfeatures,'FisherZ');                         
                    end
                else
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','TrimFeatures',nfeatures,'TreebagsOff');      
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','TrimFeatures',nfeatures);                              
                    end
                end
            end
        else
            if (holdout)
                if (zform)
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff');
                    else
                        trimmed_features = NaN;
                       [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','Holdout',holdout_data,group_holdout,'FisherZ');                        
                    end
                else
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','Holdout',holdout_data,group_holdout,'TreebagsOff');
                    else
                        trimmed_features = NaN;
                        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','Holdout',holdout_data);                        
                    end
                end
            else
                if (zform)
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','FisherZ','TreebagsOff');
                    else
                        trimmed_features = NaN;
                        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','FisherZ');                        
                    end
                else
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','TreebagsOff');
                    else
                        trimmed_features = NaN;
                        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest');                        
                    end
                end
            end
        end
    end
else
    if (estimate_trees)
        if (trim_features)
            if (holdout)
                if (zform)
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff');
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'FisherZ');                        
                    end
                else
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'TreebagsOff');
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','TrimFeatures',nfeatures,'Holdout',holdout_data);
                    end
                end
            else
                if (zform)
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','TrimFeatures',nfeatures,'FisherZ','TreebagsOff');
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','TrimFeatures',nfeatures,'FisherZ');                        
                    end
                else
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','TrimFeatures',nfeatures,'TreebagsOff');
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','TrimFeatures',nfeatures);                        
                    end
                end
            end    
        else
            if (holdout)
                if (zform)
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff');
                    else
                        trimmed_features = NaN;
                        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','Holdout',holdout_data,group_holdout,'FisherZ');                        
                    end
                else
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','Holdout',holdout_data,group_holdout,'TreebagsOff');
                    else
                        trimmed_features = NaN;
                        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','Holdout',holdout_data);                        
                    end
                end
            else
                if (zform)
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','FisherZ','TreebagsOff');    
                    else
                        trimmed_features = NaN;
                        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','FisherZ');                            
                    end
                else
                    if (disable_treebag)
                    trimmed_features = NaN;
                    [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','TreebagsOff');
                    else
                    trimmed_features = NaN;
                    [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees');                        
                    end
                end
            end
        end
    else
        if (trim_features)
            if (holdout)
                if (zform)
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff');
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'FisherZ');                        
                    end
                else
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'TreebagsOff');  
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'TrimFeatures',nfeatures,'Holdout',holdout_data);                          
                    end
                end
            else
                if (zform)
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'TrimFeatures',nfeatures,'FisherZ','TreebagsOff');
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'TrimFeatures',nfeatures,'FisherZ');                        
                    end
                else
                    if (disable_treebag)
                        [accuracy,~,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'TrimFeatures',nfeatures,'TreebagsOff');          
                    else
                        [accuracy,treebag,~,proxmat,trimmed_features] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'TrimFeatures',nfeatures);          
                    end
                end
            end                
        else
            if (holdout)
                if (zform)
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff');
                    else
                        trimmed_features = NaN;
                        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Holdout',holdout_data,group_holdout,'FisherZ');                        
                    end
                else
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Holdout',holdout_data,group_holdout,'TreebagsOff');                    
                    else
                        trimmed_features = NaN;
                        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Holdout',holdout_data);                                            
                    end
                end
            else
                if (zform)
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'FisherZ','TreebagsOff');              
                    else
                        trimmed_features = NaN;
                        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'FisherZ');                                      
                    end
                else
                    if (disable_treebag)
                        trimmed_features = NaN;
                        [accuracy,~,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'TreebagsOff');                        
                    else
                        trimmed_features = NaN;
                        [accuracy,treebag,~,proxmat] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,500);                              
                    end
                end
            end
        end
    end   
end
if nrepsPM > 0
    if (holdout)
        permute_accuracy = zeros(3,nrepsCI,max(size(struct2array(load(holdout_data)))),nrepsPM);
    else
        permute_accuracy = zeros(3,nrepsCI,nrepsPM);
    end
    tic
    for i = 1:nrepsPM
        if (weight_forest)
            if (estimate_trees)
                if (trim_features)
                    if (holdout)
                        if (zform)
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff','Permute');
                        else
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'TreebagsOff','Permute');       
                        end
                    else
                        if (zform)
                            permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','TrimFeatures',nfeatures,'FisherZ','TreebagsOff','Permute'); 
                        else
                            permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','TrimFeatures',nfeatures,'TreebagsOff','Permute');        
                        end
                    end
                else
                    if (holdout)
                        if (zform)
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff','Permute');
                        else
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','Holdout',holdout_data,group_holdout,'TreebagsOff','Permute');                            
                        end
                    else
                        if (zform)
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','FisherZ','TreebagsOff','Permute');
                        else
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','EstimateTrees','TreebagsOff','Permute');                            
                        end
                    end
                end
            else
                if (trim_features)
                    if (holdout)
                        if (zform)
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff','Permute');
                        else
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'TreebagsOff','Permute');                            
                        end
                    else
                        if (zform)
                            permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','TrimFeatures',nfeatures,'FisherZ','TreebagsOff','Permute');                        
                        else
                            permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','TrimFeatures',nfeatures,'TreebagsOff','Permute');                                                    
                        end
                    end
                else
                    if (holdout)
                        if (zform)
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff','Permute');
                        else
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','Holdout',holdout_data,group_holdout,'TreebagsOff','Permute');                            
                        end
                    else
                        if (zform)
                            permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','FisherZ','TreebagsOff','Permute');                        
                        else
                            permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'WeightForest','TreebagsOff','Permute');                                                    
                        end
                    end
                end
            end
        else
            if (estimate_trees)
                if (trim_features)
                    if (holdout)
                        if (zform)
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff','Permute');
                        else
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'TreebagsOff','Permute');                            
                        end
                    else
                        if (zform)
                            permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','TrimFeatures',nfeatures,'FisherZ','TreebagsOff','Permute');
                        else
                            permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','TrimFeatures',nfeatures,'TreebagsOff','Permute');                            
                        end
                    end
                else
                    if (holdout)
                        if (zform)
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff','Permute');
                        else
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','Holdout',holdout_data,group_holdout,'TreebagsOff','Permute');                            
                        end
                    else
                        if (zform)
                            permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','FisherZ','TreebagsOff','Permute');
                        else
                            permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'EstimateTrees','TreebagsOff','Permute');                            
                        end
                    end
                end
            else
                if (trim_features)
                    if (holdout)
                        if (zform)
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff','Permute');
                        else
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'TrimFeatures',nfeatures,'Holdout',holdout_data,group_holdout,'TreebagsOff','Permute');                            
                        end
                    else
                        if (zform)
                            permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'TrimFeatures',nfeatures,'FisherZ','TreebagsOff','Permute');                        
                        else
                            permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'TrimFeatures',nfeatures,'TreebagsOff','Permute');                                                    
                        end
                    end
                else
                    if (holdout)
                        if (zform)
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Holdout',holdout_data,group_holdout,'FisherZ','TreebagsOff','Permute');    
                        else
                            permute_accuracy(:,:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Holdout',holdout_data,group_holdout,'TreebagsOff','Permute');                                
                        end
                    else
                        if (zform)
                            permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'FisherZ','TreebagsOff','Permute');                        
                        else
                            permute_accuracy(:,:,i) = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'TreebagsOff','Permute');                                                    
                        end
                    end
                end
            end   
        end
    end
    toc
else
    permute_accuracy = NaN;
end
tic
save(strcat(filename,'.mat'),'accuracy','permute_accuracy','treebag','proxmat','trimmed_features','-v7.3');
toc
end

