function [accuracy,permute_accuracy,treebag,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_error,outofbag_varimp] = ConstructModelTreeBag(group1_data,group2_data,datasplit,nrepsCI,ntrees,nrepsPM,filename,proximity_sub_limit,varargin)
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
if exist('group2_data','var')
    if isempty(group2_data)
        group2_data = 0;
    end
else
    group2_data = 0;
end
if isstruct(group1_data)
    group1_data = struct2array(load(group1_data.path,group1_data.variable));
end
if isstruct(group2_data)
    group2_data = struct2array(load(group2_data.path,group2_data.variable));
end
holdout = 0;
if exist('proximity_sub_limit','var') == 0
    proximity_sub_limit = 500;
end
if isempty(proximity_sub_limit)
    proximity_sub_limit = 500;
end
regression = 0;
unsupervised = 0;
classification_method='classification';
lowdensity = 0.2;
highdensity = 1;
stepdensity = 0.05;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
            switch(varargin{i})
                case('Holdout')
                    holdout = 1;
                    holdout_data = varargin{i+1};
                case('Regression')
                    regression = 1;
                    classification_method='regression';
                case('unsupervised')
                    unsupervised = 1;
                case('LowDensity')
                    lowdensity = varargin{i+1};
                case('HighDensity')
                    highdensity = varargin{i+1};
                case('StepDensity')
                    stepdensity = varargin{i+1};                    
            end
        end
    end
end
switch(size(varargin,2))
    case(0)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit);
    case(1)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1});
    case(2)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2});        
    case(3)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3});         
    case(4)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4});                 
    case(5)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5});                         
    case(6)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6});                                 
    case(7)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7});                                         
    case(8)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8});                                         
    case(9)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9});                                                 
    case(10)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10});                                                         
    case(11)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11});                                                                 
    case(12)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12});                                                                         
    case(13)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13});                                                                                 
    case(14)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14});
    case(15)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15});                                                                                         
    case(16)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16});                                                                                         
    case(17)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17});
    case(18)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18});
    case(19)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19});
    case(20)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20});
    case(21)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20}, varargin{21});        
    case(22)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20}, varargin{21}, varargin{22});        
    case(23)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20}, varargin{21}, varargin{22}, varargin{23});        
    case(24)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20}, varargin{21}, varargin{22}, varargin{23},varargin{24});
    case(25)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20}, varargin{21}, varargin{22}, varargin{23},varargin{24},varargin{25});                
    case(26)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20}, varargin{21}, varargin{22}, varargin{23},varargin{24},varargin{25},varargin{26});
    case(27)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20}, varargin{21}, varargin{22}, varargin{23},varargin{24},varargin{25},varargin{26},varargin{27});  
    case(28)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20}, varargin{21}, varargin{22}, varargin{23},varargin{24},varargin{25},varargin{26},varargin{27},varargin{28});  
    case(29)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20}, varargin{21}, varargin{22}, varargin{23},varargin{24},varargin{25},varargin{26},varargin{27},varargin{28},varargin{29});
    case(30)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20}, varargin{21}, varargin{22}, varargin{23},varargin{24},varargin{25},varargin{26},varargin{27},varargin{28},varargin{29},varargin{30});  
    case(31)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20}, varargin{21}, varargin{22}, varargin{23},varargin{24},varargin{25},varargin{26},varargin{27},varargin{28},varargin{29},varargin{30});  
    case(32)
        [accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20}, varargin{21}, varargin{22}, varargin{23},varargin{24},varargin{25},varargin{26},varargin{27},varargin{28},varargin{29},varargin{30},varargin{31});          
end
if nrepsPM > 0
    tic
    for i = 1:nrepsPM
        switch(size(varargin,2))
            case(0)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute');
            case(1)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1});               
            case(2)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2});
            case(3)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3});                 
            case(4)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4});                
            case(5)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5});                 
            case(6)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6});                 
            case(7)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7});                 
            case(8)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8});              
            case(9) 
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9});                             
            case(10)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10});             
            case(11)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11});
            case(12)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12});                
            case(13)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13});                                
            case(14)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14});
            case(15)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15});                                                
            case(16)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16});                                                
            case(17)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17});                                                                
            case(18)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18});          
            case(19)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19});   
            case(20)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20});
            case(21)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20},varargin{21});                 
            case(22)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20},varargin{21},varargin{22});                 
            case(23)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20},varargin{21},varargin{22},varargin{23});                 
            case(24)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20},varargin{21},varargin{22},varargin{23},varargin{24});                 
            case(25)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20},varargin{21},varargin{22},varargin{23},varargin{24},varargin{25});                 
            case(26)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20},varargin{21},varargin{22},varargin{23},varargin{24},varargin{25},varargin{26});                 
            case(27)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20},varargin{21},varargin{22},varargin{23},varargin{24},varargin{25},varargin{26},varargin{27});                 
            case(28)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20},varargin{21},varargin{22},varargin{23},varargin{24},varargin{25},varargin{26},varargin{27},varargin{28});                 
            case(29)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20},varargin{21},varargin{22},varargin{23},varargin{24},varargin{25},varargin{26},varargin{27},varargin{28},varargin{29});                 
            case(30)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20},varargin{21},varargin{22},varargin{23},varargin{24},varargin{25},varargin{26},varargin{27},varargin{28},varargin{29},varargin{30});                 
            case(31)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20},varargin{21},varargin{22},varargin{23},varargin{24},varargin{25},varargin{26},varargin{27},varargin{28},varargin{29},varargin{30},varargin{31});                 
            case(32)
                permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}, varargin{20},varargin{21},varargin{22},varargin{23},varargin{24},varargin{25},varargin{26},varargin{27},varargin{28},varargin{29},varargin{30},varargin{31},varargin{32});                 
        end
        if i == 1
            if (holdout)
                permute_accuracy = zeros(size(permute_accuracy_temp,1),nrepsCI,max(size(struct2array(load(holdout_data)))),nrepsPM);
            else
                permute_accuracy = zeros(size(permute_accuracy_temp,1),nrepsCI,nrepsPM);
            end
        end
        if (holdout)
            permute_accuracy(:,:,:,i) = permute_accuracy_temp;
        else
            permute_accuracy(:,:,i) = permute_accuracy_temp;
        end
    end
    toc
else
    permute_accuracy = NaN;
end
tic
if unsupervised
    proxmat_new = cell(length(proxmat),1);
    nsubs = size(proxmat{1},1)/2;
    for i = 1:length(proxmat)
        proxmat_new{i} = proxmat{i}(1:nsubs,1:nsubs);
    end
    clear proxmat
    proxmat = proxmat_new;
    clear proxmat_new
end
save(strcat(filename,'.mat'),'accuracy','permute_accuracy','treebag','proxmat','features','trimmed_features','npredictors','group1class','group2class','outofbag_error','outofbag_varimp','-v7.3');
toc
sprintf('%s','Calculating confidence intervals for Treebagging completed! Computing community detection using simple_infomap.py')
command_file = '/group_shares/PSYCH/code/release/utilities/simple_infomap/simple_infomap.py';
VisualizeTreeBaggingResults(strcat(filename,'.mat'),strcat(filename,'_output'),classification_method,group1_data,group2_data,command_file,'LowDensity',lowdensity,'StepDensity',stepdensity,'HighDensity',highdensity);
end

