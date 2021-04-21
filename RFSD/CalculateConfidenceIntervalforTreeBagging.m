function [accuracy,treebag,outofbag_error,proxmat,features_used,trimmed_feature_sets,npredictor_sets,group1class,group2class,outofbag_varimp,final_data,dim_data,final_outcomes,group1predict,group2predict,group1scores,group2scores,group1_data,group2_data] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nreps,proximity_sub_limit,varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if exist('proximity_sub_limit','var') == 0
    proximity_sub_limit = 500;
end
if isempty(proximity_sub_limit)
    proximity_sub_limit = 500;
end

estimate_trees = 0;
weight_forest = 0;
trim_features = 0;
disable_treebag = 0;
holdout = 0;
zform = 0;
permute_data = 0;
estimate_predictors = 0;
estimate_tree_predictors = 0;
OOB_error_on = 0;
class_method = 'classification';
surrogate = 'off';
regression = 0;
group2test = 0;
prior = 'Empirical';
independent_outcomes = 0;
unsupervised = 0;
matchgroups = 0;
cross_valid = 0;
dim_reduce = false;
final_outcomes = NaN;
dim_data = NaN;
modules = 0;
dim_type = 'PCA';
num_components = 1;
graph_reduce = false;
connmat_reduce = false;
systems = 0;
edgedensity = 0.05;
if ischar(nreps)
    nreps = str2num(nreps);
end
if ischar(ntrees)
    ntrees = str2num(ntrees);
end
if ischar(proximity_sub_limit)
    proximity_sub_limit = str2num(proximity_sub_limit);
end
if ischar(datasplit)
    datasplit = str2num(datasplit);
end
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
           if (isnumeric(varargin{i}) && size(varargin{i},1) > 1) == 0
               switch(varargin{i})
                    case('EstimateTrees')
                        estimate_trees = 1;
                    case('WeightForest')
                        weight_forest = 1;
                    case('TrimFeatures')
                        trim_features = 1;
                        nfeatures = varargin{i+1};
                        if ischar(nfeatures)
                            nfeatures = str2num(nfeatures);
                        end
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
                    case('npredictors')
                        npredictors = varargin{i+1};
                        if ischar(npredictors)
                            npredictors = str2num(npredictors);
                        end
                    case('EstimatePredictors')
                        estimate_predictors = 1;
                    case('OOBErrorOn')
                        OOB_error_on = 1;                    
                    case('EstimateTreePredictors')
                       estimate_tree_predictors = 1;
                    case('Regression')
                        regression = 1;
                        class_method = 'regression';
                    case('useoutcomevariable')
                        independent_outcomes = 1;
                        if isnumeric(varargin{i+1}) && isscalar(varargin{i+1})
                            group1_outcome = group1_data(:,varargin{i+1});
                            index = true(1, size(group1_data,2));
                            index([varargin{i+1}]) = false;
                            group1_data = group1_data(:,index);
                            clear index
                        elseif isnumeric(varargin{i+1}) && ismatrix(varargin{i+1})
                            group1_outcome = varargin{i+1};
                        elseif isstruct(varargin{i+1})
                            group1_outcome = struct2array(load(varargin{i+1}.path,varargin{i+1}.variable));
                        elseif ischar(varargin{i+1}) && strcmp(varargin{i+1}(end-3:end),'.mat')
                            group1_outcome = struct2array(load(varargin{i+1},varargin{i+2}));
                        end
                        if iscell(group1_outcome)
                            group1_outcome = cell2mat(group1_outcome);
                        end
                        if size(group2_data,1) == 1 && size(group2_data,2) == 1
                        elseif isnumeric(varargin{i+2}) && isscalar(varargin{i+2})
                            group2_outcome = group2_data(:,varargin{i+2});
                            index = true(1, size(group2_data,2));
                            index([varargin{i+1}]) = false;
                            group2_data = group2_data(:,index);
                            clear index
                        elseif isnumeric(varargin{i+2}) && ismatrix(varargin{i+2})
                            group2_outcome = varargin{i+2};
                        elseif isstruct(varargin{i+2})
                            group2_outcome = struct2array(load(varargin{i+2}.path,varargin{i+2}.variable));
                        elseif ischar(varargin{i+3}) && strcmp(varargin{i+3}(end-3:end),'.mat')
                            group2_outcome = struct2array(load(varargin{i+3},varargin{i+4}));
                        end
                        if size(group2_data,1) > 1 || size(group2_data,2) > 1
                            if iscell(group2_outcome)
                                group2_outcome = cell2mat(group2_outcome);
                            end
                        end
                    case('surrogate')
                        surrogate = 'on';
                    case('group2istestdata')
                        group2test = 1;
                    case('Prior')
                        prior = varargin{i+1};
                    case('unsupervised')
                        group2_data = group1_data;
                        unsupervised = 1;
                    case('MatchGroups')
                        matchgroups = 1;
                    case('CrossValidate')
                       holdout = 2;
                       nfolds = varargin{i+1};
                       if ischar(nfolds)
                           nfolds = str2num(nfolds);
                       end
                   case('DimReduce')
                       dim_reduce = true;
                       if ischar(varargin{i+1}) && strcmp(varargin{i+1}(end-3:end),'.mat')
                        modules = struct2array(load(varargin{i+1},varargin{i+2}));
                        dim_type = varargin{i+3};
                        num_components = varargin{i+4};
                        if ischar(num_components)
                            num_components = str2num(numcomponents);
                        end
                       elseif isstruct(varargin{i+1})
                        modules = struct2array(load(varargin{i+1}.path,varargin{i+1}.variable));
                        dim_type = varargin{i+2};
                        num_components = varargin{i+3};
                        if ischar(num_components)
                            num_components = str2num(numcomponents);
                        end                    
                       end
                   case('GraphReduce')
                       graph_reduce = true;
                       if ischar(varargin{i+1}) && strcmp(varargin{i+1}(end-3:end),'.mat')
                        systems = struct2array(load(varargin{i+1},varargin{i+2}));
                        modules = struct2array(load(varargin{i+3},varargin{i+4}));
                        edgedensity = varargin{i+5};
                        if ischar(edgedensity)
                            edgedensity = str2num(edgedensity);
                        end
                        bctpath = varargin{i+6};                       
                       elseif isstruct(varargin{i+1})
                        systems = struct2array(load(varargin{i+1}.path,varargin{i+1}.variable));
                        modules = struct2array(load(varargin{i+2}.path,varargin{i+2}.variable));
                        edgedensity = varargin{i+3};
                        if ischar(edgedensity)
                            edgedensity = str2num(edgedensity);
                        end                    
                        bctpath = varargin{i+4};
                       end
                   case('ConnMatReduce')
                       connmat_reduce = true;
               end
           end
        end
    end
end
if connmat_reduce
    if group2_data ~= 0
        dim_data = group1_data;
        dim_data(:,:,end+1:end+size(group2_data,3)) = group2_data;
        group1_3ddata = group1_data;
        group2_3ddata =group2_data;
        group1_data = Convert3dConnMatTo2dCaseMat(group1_3ddata);
        clear group1_3ddata
        group2_data = Convert3dConnMatTo2dCaseMat(group2_3ddata);
        clear group2_3ddata
    else
        dim_data = group1_data;
        group1_3ddata = group1_data;
        group1_data = Convert3dConnMatTo2dCaseMat(group1_3ddata);
        clear group1_3ddata
    end
end
if graph_reduce
    dim_data = group1_data;
    group1_data = ModuleFeatureExtractor('InputData',dim_data,'Modules',modules,'DimType','graph','EdgeDensity',edgedensity,'BCTPath',bctpath,'Systems',systems);
end
if iscell(group1_data)
    [categorical_vector, group1_data] = ConvertCelltoMatrixforTreeBagging(group1_data);
else
    categorical_vector = logical(zeros(size(group1_data,2),1));
end
if iscell(group2_data)
    [categorical_vector, group2_data] = ConvertCelltoMatrixforTreeBagging(group2_data);
end
if holdout ~= 1
    holdout_data = 0;
end
if independent_outcomes
    if regression == 0
        accuracy = zeros(max(size(unique(group1_outcome)))+1,nreps,max(size(holdout_data)));
    else
        accuracy = zeros(3,nreps,max(size(holdout_data)));
    end
    if group2_data == 0
        %edited code to remove the random shuffle here, please report if
        %errors or odd results occur.
        %rng('shuffle');
        %shuffled_subs = randperm(nsubs);
        nsubs = size(group1_data,1);
        group2_data = group1_data(floor(nsubs/2)+1:end,:);
        group1_data = group1_data(1:floor(nsubs/2),:);
        group2_outcome = group1_outcome(floor(nsubs/2)+1:end);
        group1_outcome = group1_outcome(1:floor(nsubs/2));
        if holdout == 0
%            group2_data = group1_data(shuffled_subs(floor(nsubs/2)+1:end),:);
%            group1_data = group1_data(shuffled_subs(1:floor(nsubs/2)),:);
%            group2_outcome = group1_outcome(shuffled_subs(floor(nsubs/2)+1:end));
%            group1_outcome = group1_outcome(shuffled_subs(1:floor(nsubs/2)));
        else
%            group2_data = group1_data(floor(nsubs/2)+1:end,:);
%            group1_data = group1_data(1:floor(nsubs/2),:);
%            group2_outcome = group1_outcome(floor(nsubs/2)+1:end);
%            group1_outcome = group1_outcome(1:floor(nsubs/2));
            cross_valid = 1;
        end
        size(group1_outcome)
        size(group2_outcome)
    end
else
    accuracy = zeros(3,nreps,max(size(holdout_data)));
end
categorical_vectors_to_use = categorical_vector;
if (zform)
    group1_data = rtoz(group1_data);
    group2_data = rtoz(group2_data);
end
[nsubs_group1, nvars] = size(group1_data);
nsubs_group2 = size(group2_data,1);
group1class = zeros(nsubs_group1,1);
group2class = zeros(nsubs_group2,1);
group1predict = zeros(nsubs_group1,1);
group2predict = zeros(nsubs_group2,1);
if regression == 0
    group1scores = zeros(nsubs_group1,length(unique(group1_outcome)));
    group2scores = zeros(nsubs_group2,length(unique(group2_outcome)));
    group2class_scored = zeros(nsubs_group2,length(unique(group1_outcome)));
    group1class_scored = zeros(nsubs_group1,length(unique(group1_outcome)));  
else
    group1scores = zeros(nsubs_group1,1);
    group2scores = zeros(nsubs_group2,1);
    group2class_scored = zeros(nsubs_group2,1);
    group1class_scored = zeros(nsubs_group1,1);     
end
group1class_tested = zeros(nsubs_group1,1);
group1class_predicted = zeros(nsubs_group1,1);
group2class_tested = zeros(nsubs_group2,1);
group2class_predicted = zeros(nsubs_group2,1);
if exist('npredictors','var') == 0
    npredictors = round(sqrt(nvars));
end
if (estimate_predictors)
    npredictor_sets = zeros(nreps,1);
else
    npredictor_sets = NaN;
end
if nsubs_group1 >= nsubs_group2*10
    sprintf('Groups are too unbalanced, will force group1 to be the size of group2 for model construction')
    matchsubs_group1 = nsubs_group2;
    matchsubs_group2 = nsubs_group2;
elseif nsubs_group2 >= nsubs_group1*10
    sprintf('Groups are too unbalanced, will force group2 to be the size of group1 for model construction')    
    matchsubs_group2 = nsubs_group1;
    matchsubs_group1 = nsubs_group1;
elseif (matchgroups)
    if nsubs_group1 > nsubs_group2
        matchsubs_group2 = nsubs_group2;
        matchsubs_group1 = nsubs_group2;
    else
        matchsubs_group2 = nsubs_group1;
        matchsubs_group1 = nsubs_group1;
    end
else
    matchsubs_group1 = nsubs_group1;
    matchsubs_group2 = nsubs_group2;
end
if disable_treebag == 0
    treebag = cell(nreps,max(size(holdout_data)));
end
proxmat = cell(nreps,max(size(holdout_data)));
outofbag_error = zeros(nreps,ntrees,max(size(holdout_data)));
if (trim_features)
    trimmed_feature_sets = zeros(nreps,nfeatures,max(size(holdout_data)));
    nvars = nfeatures;
else
    trimmed_feature_sets = NaN;
end
outofbag_varimp = zeros(nreps,nvars,max(size(holdout_data)));
features_used = zeros(nvars,1);
if holdout == 0
    if group2test && independent_outcomes
        testing_data = group2_data;
        testing_indexgroup1 = 0;
        testing_indexgroup2 = 1:nsubs_group2;
        learning_data = group1_data;
        learning_groups = group1_outcome;
        testing_groups = group2_outcome;
        all_data = group1_data;
        all_data(end+1:end+size(group2_data,1),:) = group2_data;
    elseif matchgroups
        learning_groups = zeros(floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),1);
        testing_groups = zeros(nsubs_group1 - (floor(matchsubs_group1*datasplit)) + nsubs_group2 - (floor(matchsubs_group2*datasplit)),1);
        learning_groups(1:floor(matchsubs_group1*datasplit),1) = 0;
        learning_groups(floor(matchsubs_group1*datasplit)+1:floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),1) = 1;
        testing_groups(1:nsubs_group1 - (floor(matchsubs_group1*datasplit)),1) = 0;
        testing_groups(nsubs_group1 - (floor(matchsubs_group1*datasplit)) + 1:nsubs_group1 - (floor(matchsubs_group1*datasplit)) + nsubs_group2 - (floor(matchsubs_group2*datasplit)),1) = 1;
        learning_data = zeros(floor(matchsubs_group1*datasplit) + floor(matchsubs_group2*datasplit),nvars);
        testing_data = zeros(nsubs_group1 - floor(matchsubs_group1*datasplit) + nsubs_group2 - floor(matchsubs_group2*datasplit),nvars);       
    else
        learning_groups = zeros(floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),1);
        testing_groups = zeros(matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + matchsubs_group2 - (floor(matchsubs_group2*datasplit)),1);
        learning_groups(1:floor(matchsubs_group1*datasplit),1) = 0;
        learning_groups(floor(matchsubs_group1*datasplit)+1:floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),1) = 1;
        testing_groups(1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)),1) = 0;
        testing_groups(matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + 1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + matchsubs_group2 - (floor(matchsubs_group2*datasplit)),1) = 1;
        learning_data = zeros(floor(matchsubs_group1*datasplit) + floor(matchsubs_group2*datasplit),nvars);
        testing_data = zeros(matchsubs_group1 - floor(matchsubs_group1*datasplit) + matchsubs_group2 - floor(matchsubs_group2*datasplit),nvars);
    end
    tic
    if nsubs_group1 + nsubs_group2 <= proximity_sub_limit
        for i = 1:nreps
            if (unsupervised)
                group2_data = group1_data;
                rng('shuffle');
                all_vector = 1:nsubs_group2;
                group2_data_temp = zeros(size(group2_data,1),size(group2_data,2));
                group2_data_temp(:,1) = group2_data(:,1);
                for subject_index = 1:nsubs_group2
                    subject_vector = all_vector(find(all_vector ~= subject_index));
                    for feature_index = 2:nvars
                        new_subject = subject_vector(randi(length(subject_vector)));
                        subject_vector = subject_vector(find(subject_vector ~= new_subject));
                        group2_data_temp(subject_index,feature_index) = group2_data(new_subject,feature_index);
                        if isempty(subject_vector)
                           sprintf('%s','number of features greater than number of subjects, unsupervised alogrithm will be partially supervised');
                           subject_vector = all_vector(find(all_vector ~= subject_index));
                        end
                    end
                end
                group2_data = group2_data_temp;
            end
            if group2test == 0 || independent_outcomes == 0
                rng('shuffle');
                all_data = group1_data;
                all_data(end+1:end+nsubs_group2,:) = group2_data;
                if matchgroups == 0
                    group1_subjects = randperm(nsubs_group1,matchsubs_group1);
                    group2_subjects = randperm(nsubs_group2,matchsubs_group2);
                    resample_group1_data = group1_data(group1_subjects,:);
                    resample_group2_data = group2_data(group2_subjects,:);
                    testing_indexgroup1 = group1_subjects(floor(matchsubs_group1*datasplit)+1:matchsubs_group1);
                    testing_indexgroup2 = group2_subjects(floor(matchsubs_group2*datasplit)+1:matchsubs_group2);   
                else
                    group1_subjects = randperm(nsubs_group1,nsubs_group1);
                    group2_subjects = randperm(nsubs_group2,nsubs_group2);
                    resample_group1_data = group1_data(group1_subjects,:);
                    resample_group2_data = group2_data(group2_subjects,:);
                    testing_indexgroup1 = group1_subjects(floor(matchsubs_group1*datasplit)+1:nsubs_group1);
                    testing_indexgroup2 = group2_subjects(floor(matchsubs_group2*datasplit)+1:nsubs_group2);  
                end                              
                if (independent_outcomes)
                    final_outcomes = [group1_outcome; group2_outcome];
                    resample_group1_outcome = group1_outcome(group1_subjects);
                    resample_group2_outcome = group2_outcome(group2_subjects);
                end
                if (trim_features)
                    [~,~,trimmed_features] = KSFeatureTrimmer(resample_group1_data(1:floor(matchsubs_group1*datasplit),:),resample_group2_data(1:floor(matchsubs_group2*datasplit),:),nfeatures);
                    resample_group1_data = group1_data(group1_subjects,trimmed_features);
                    resample_group2_data = group2_data(group2_subjects,trimmed_features);
                    trimmed_feature_sets(i,:) = trimmed_features;
                    all_data = all_data(:,trimmed_features);
                    categorical_vectors_to_use = categorical_vector(trimmed_features);
                end
                if (permute_data)
                    permall_data = resample_group1_data;
                    permall_data(size(resample_group1_data,1)+1:size(resample_group1_data,1)+size(resample_group2_data,1),:) = resample_group2_data;
                    permall_data_temp = permall_data(randperm(size(resample_group1_data,1)+size(resample_group2_data,1)),:);
                    if matchgroups
                        perm1_data = permall_data_temp(1:nsubs_group1,:);
                        perm2_data = permall_data_temp(nsubs_group1+1:nsubs_group1+nsubs_group2,:);
                    else
                        perm1_data = permall_data_temp(1:matchsubs_group1,:);
                        perm2_data = permall_data_temp(matchsubs_group1+1:matchsubs_group1+matchsubs_group2,:);
                    end
                    resample_group1_data = perm1_data;
                    resample_group2_data = perm2_data;
                    clear permall_data permall_data_temp perm1_data perm2_data
                end
                if matchgroups
                    learning_data(1:floor(matchsubs_group1*datasplit),:) = resample_group1_data(1:floor(matchsubs_group1*datasplit),:);
                    learning_data(floor(matchsubs_group1*datasplit)+1:floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),:) = resample_group2_data(1:floor(matchsubs_group2*datasplit),:);
                    testing_data(1:nsubs_group1 - (floor(matchsubs_group1*datasplit)),:) = resample_group1_data(floor(matchsubs_group1*datasplit)+1:nsubs_group1,:);
                    testing_data(nsubs_group1 - (floor(matchsubs_group1*datasplit)) + 1:nsubs_group1 - (floor(matchsubs_group1*datasplit)) + nsubs_group2 - (floor(matchsubs_group2*datasplit)),:) = resample_group2_data(floor(matchsubs_group2*datasplit)+1:nsubs_group2,:);
                else
                    learning_data(1:floor(matchsubs_group1*datasplit),:) = resample_group1_data(1:floor(matchsubs_group1*datasplit),:);
                    learning_data(floor(matchsubs_group1*datasplit)+1:floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),:) = resample_group2_data(1:floor(matchsubs_group2*datasplit),:);
                    testing_data(1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)),:) = resample_group1_data(floor(matchsubs_group1*datasplit)+1:matchsubs_group1,:);
                    testing_data(matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + 1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + matchsubs_group2 - (floor(matchsubs_group2*datasplit)),:) = resample_group2_data(floor(matchsubs_group2*datasplit)+1:matchsubs_group2,:);
                end
                if (independent_outcomes)
                    learning_groups(1:floor(matchsubs_group1*datasplit),1) = resample_group1_outcome(1:floor(matchsubs_group1*datasplit),1);
                    learning_groups(floor(matchsubs_group1*datasplit)+1:floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),1) = resample_group2_outcome(1:floor(matchsubs_group2*datasplit),:);
                    testing_groups(1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)),1) = resample_group1_outcome(floor(matchsubs_group1*datasplit)+1:matchsubs_group1,:);
                    testing_groups(matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + 1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + matchsubs_group2 - (floor(matchsubs_group2*datasplit)),1) = resample_group2_outcome(floor(matchsubs_group2*datasplit)+1:matchsubs_group2,:);
                end
            end
            if group2test && independent_outcomes && permute_data
                rng('shuffle');
                learning_data = learning_data(randperm(nsubs_group1),:);
                testing_data = testing_data(randperm(nsubs_group2),:);                
            end
            if dim_reduce
                training_data = ModuleFeatureExtractor('InputData',training_data,'Modules',modules,'DimType',dim_type,'NumComponents',num_components);
                testing_data = ModuleFeatureExtractor('InputData',testing_data,'Modules',modules,'DimType',dim_type,'NumComponents',num_components);
                categorical_vectors_to_use = logical(zeros(size(training_data,2)));
                dim_data = zeros(size(training_data,1)+size(testing_data,1),size(testing_data,2));
                dim_data(training_selection,:) = training_data;
                dim_data(testing_selection,:) = testing_data;
            end
            if (estimate_tree_predictors)
                npredictors_used = TestTreeBags(learning_groups,learning_data,[],[],ntrees,'EstimatePredictorsToSample',0,0,categorical_vectors_to_use,'npredictors',npredictors,'surrogate',surrogate, 'Prior', prior);
            else
                npredictors_used = npredictors;
            end
            if (estimate_trees)
                [ntrees_est,~,outofbag_error_temp] = TestTreeBags(learning_groups,learning_data,[],[],ntrees,'estimate_trees',0,0,categorical_vectors_to_use,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior);
                size(outofbag_error_temp)
                outofbag_error(i,1:length(outofbag_error_temp)) = outofbag_error_temp;
            else
                ntrees_est = ntrees;
            end
            if (estimate_predictors)
                [accuracy(:,i),treebag_temp,outofbag_error(i,:),outofbag_varimp(i,:),group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validationPlusOOB',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
            elseif (OOB_error_on)
                [accuracy(:,i),treebag_temp,outofbag_error(i,:),~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation_OOBerror',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);                
            elseif (weight_forest)
                [tree_weights,treebag_temp] = TestTreeBags(learning_groups,learning_data,[],[],ntrees_est,'weight_trees',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior);
                [accuracy(:,i),~,~,~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags([],[], testing_groups, testing_data,ntrees_est,'validation_weighted',treebag_temp,tree_weights,categorical_vectors_to_use,class_method,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);            
            elseif (estimate_trees)
                [accuracy(:,i),treebag_temp,~,~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
            else
                [accuracy(:,i),treebag_temp,outofbag_error(i,:),outofbag_varimp(i,:),group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
            end
            if group2test == 0
                proxmat{i,1} = proximity(treebag_temp.compact,all_data);
            else
                proxmat{i,1} = proximity(treebag_temp.compact,testing_data);
            end
            features_used = features_used + CollateUsedFeatures(treebag_temp.Trees,nvars);
            if disable_treebag == 0
                treebag{i,1} = treebag_temp;
            end
            if testing_indexgroup1 > 0
                testing_indexgroup1
                size(group1scores)
                size(group1scores_temp)
                group1class(testing_indexgroup1) = group1class(testing_indexgroup1) + group1class_temp;
                group1predict(testing_indexgroup1) = group1predict(testing_indexgroup1) + group1predict_temp;
                if regression == 0
                    group1scores(testing_indexgroup1,:) = group1scores(testing_indexgroup1,:) + group1scores_temp;
                end
                group1class_predicted(testing_indexgroup1) = group1class_predicted(testing_indexgroup1) + 1;
                group1class_tested(testing_indexgroup1) = group1class_tested(testing_indexgroup1) + 1;
                group1class_scored(testing_indexgroup1,:) = group1class_scored(testing_indexgroup1,:) + 1;
            end
            if testing_indexgroup2 > 0
                testing_indexgroup2
                size(group2scores)
                size(group2scores_temp)
                group2class(testing_indexgroup2) = group2class(testing_indexgroup2) + group2class_temp;
                group2predict(testing_indexgroup2) = group2predict(testing_indexgroup2) + group2predict_temp;
                if regression == 0
                    group2scores(testing_indexgroup2,:) = group2scores(testing_indexgroup2,:) + group2scores_temp;
                end
                group2class_predicted(testing_indexgroup2) = group2class_predicted(testing_indexgroup2) + 1;
                group2class_tested(testing_indexgroup2) = group2class_tested(testing_indexgroup2) + 1;
                group2class_scored(testing_indexgroup2,:) = group2class_scored(testing_indexgroup2,:) + 1;
            end            
            clear treebag_temp group1class_temp group2class_temp
            sprintf('%s',strcat('run #',num2str(i),' cumulative accuracy=',num2str(mean(accuracy(1,1:i)))))
        end
        group1class = group1class./group1class_tested;
        group2class = group2class./group2class_tested;
        group1predict = group1predict./group1class_predicted;
        group2predict = group2predict./group2class_tested;
        group1scores = group1scores./group1class_scored;
        group2scores = group2scores./group2class_scored;
        if group2test == 0
            final_data = all_data;
        else
            final_data = testing_data;
            final_outcomes = testing_groups;
        end
    else
        for i = 1:nreps
            if (unsupervised)
                rng('shuffle');
                all_vector = 1:nsubs_group2;
                group2_data = group1_data;
                group2_data_temp = zeros(size(group2_data,1),size(group2_data,2));
                group2_data_temp(:,1) = group2_data(:,1);
                for subject_index = 1:nsubs_group2
                    subject_vector = all_vector(find(all_vector ~= subject_index));
                    for feature_index = 2:nvars
                        new_subject = subject_vector(randi(length(subject_vector)));
                        subject_vector = subject_vector(find(subject_vector ~= new_subject));
                        group2_data_temp(subject_index,feature_index) = group2_data(new_subject,feature_index);
                        if isempty(subject_vector)
                           sprintf('%s','number of features greater than number of subjects, unsupervised alogrithm will be partially supervised');
                           subject_vector = all_vector(find(all_vector ~= subject_index));
                        end
                    end
                end
                group2_data = group2_data_temp;
            end
            if group2test == 0 || independent_outcomes == 0
                rng('shuffle');
                group1_subjects = randperm(nsubs_group1,matchsubs_group1);
                group2_subjects = randperm(nsubs_group2,matchsubs_group2);
                resample_group1_data = group1_data(group1_subjects,:);
                resample_group2_data = group2_data(group2_subjects,:);
                testing_indexgroup1 = group1_subjects(floor(matchsubs_group1*datasplit)+1:matchsubs_group1);
                testing_indexgroup2 = group2_subjects(floor(matchsubs_group2*datasplit)+1:matchsubs_group2);                              
                all_data = group1_data(sort(group1_subjects),:);
                all_data(end+1:end+matchsubs_group2,:) = group2_data(sort(group2_subjects),:);  
                if (independent_outcomes)
                    final_outcomes = [group1_outcome; group2_outcome];                    
                    resample_group1_outcome = group1_outcome(group1_subjects);
                    resample_group2_outcome = group2_outcome(group2_subjects);
                end
                if (trim_features)
                    [~,~,trimmed_features] = KSFeatureTrimmer(resample_group1_data(1:floor(matchsubs_group1*datasplit),:),resample_group2_data(1:floor(matchsubs_group2*datasplit),:),nfeatures);
                    resample_group1_data = group1_data(group1_subjects,trimmed_features);
                    resample_group2_data = group2_data(group2_subjects,trimmed_features);
                    trimmed_feature_sets(i) = trimmed_features;
                    categorical_vectors_to_use = categorical_vector(trimmed_features);                
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
                if (independent_outcomes)
                    learning_groups(1:floor(matchsubs_group1*datasplit),1) = resample_group1_outcome(1:floor(matchsubs_group1*datasplit),1);
                    learning_groups(floor(matchsubs_group1*datasplit)+1:floor(matchsubs_group1*datasplit)+floor(matchsubs_group2*datasplit),1) = resample_group2_outcome(1:floor(matchsubs_group2*datasplit),:);
                    testing_groups(1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)),1) = resample_group1_outcome(floor(matchsubs_group1*datasplit)+1:matchsubs_group1,:);
                    testing_groups(matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + 1:matchsubs_group1 - (floor(matchsubs_group1*datasplit)) + matchsubs_group2 - (floor(matchsubs_group2*datasplit)),1) = resample_group2_outcome(floor(matchsubs_group2*datasplit)+1:matchsubs_group2,:);
                end
            end
            if group2test && independent_outcomes && permute_data
                rng('shuffle');
                learning_data = learning_data(randperm(nsubs_group1),:);
                testing_data = testing_data(randperm(nsubs_group2),:);  
            end
            if dim_reduce
                training_data = ModuleFeatureExtractor('InputData',training_data,'Modules',modules,'DimType',dim_type,'NumComponents',num_components);
                testing_data = ModuleFeatureExtractor('InputData',testing_data,'Modules',modules,'DimType',dim_type,'NumComponents',num_components);
                categorical_vectors_to_use = logical(zeros(size(training_data,2)));
                dim_data = zeros(size(training_data,1)+size(testing_data,1),size(testing_data,2));
                dim_data(training_selection,:) = training_data;
                dim_data(testing_selection,:) = testing_data;
            end
            if (estimate_tree_predictors)
                npredictors_used = TestTreeBags(learning_groups,learning_data,[],[],ntrees,'EstimatePredictorsToSample',0,0,categorical_vectors_to_use,'npredictors',npredictors,'surrogate',surrogate, 'Prior', prior);
            else
                npredictors_used = npredictors;
            end            
            if (estimate_trees)
                [ntrees_est,~,outofbag_error_temp] = TestTreeBags(learning_groups,learning_data,[],[],ntrees,'estimate_trees',0,0,categorical_vectors_to_use,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior);
                size(outofbag_error_temp)
                outofbag_error(i,1:length(outofbag_error_temp)) = outofbag_error_temp;
            else
                ntrees_est = ntrees;
            end
            if (estimate_predictors)
                [accuracy(:,i),treebag_temp,outofbag_error(i,:),outofbag_varimp(i,:),group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validationPlusOOB',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
            elseif (OOB_error_on)
                [accuracy(:,i),treebag_temp,outofbag_error(i,:),~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation_OOBerror',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);                
            elseif (weight_forest)
                [tree_weights,treebag_temp] = TestTreeBags(learning_groups,learning_data,[],[],ntrees_est,'weight_trees',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior);
                [accuracy(:,i),~,~,~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags([],[], testing_groups, testing_data,ntrees_est,'validation_weighted',treebag_temp,tree_weights,categorical_vectors_to_use,class_method,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);            
            elseif (estimate_trees)
                [accuracy(:,i),treebag_temp,~,~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
            else
                [accuracy(:,i),treebag_temp,outofbag_error(i,:),outofbag_varimp(i,:),group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
            end          
            if (trim_features)
                all_data = all_data(:,trimmed_features);
            end
            proxmat{i,1} = proximity(treebag_temp.compact,all_data);
            features_used = features_used + CollateUsedFeatures(treebag_temp.Trees,nvars);
            if disable_treebag == 0
                treebag{i,1} = treebag_temp;
            end
            if testing_indexgroup1 > 0
                group1class(testing_indexgroup1) = group1class(testing_indexgroup1) + group1class_temp;
                group1predict(testing_indexgroup1) = group1predict(testing_indexgroup1) + group1predict_temp;
                group1scores(testing_indexgroup1) = group1scores(testing_indexgroup1) + group1scores_temp';
                group1class_predicted(testing_indexgroup1) = group1class_predicted(testing_indexgroup1) + 1;
                group1class_tested(testing_indexgroup1) = group1class_tested(testing_indexgroup1) + 1;
                group1class_scored(testing_indexgroup1) = group1class_scored(testing_indexgroup1) + 1;
            end
            if testing_indexgroup2 > 0
                group2class(testing_indexgroup2) = group2class(testing_indexgroup2) + group2class_temp;
                group2predict(testing_indexgroup2) = group2predict(testing_indexgroup2) + group2predict_temp;
                group2scores(testing_indexgroup2) = group2predict(testing_indexgroup2) + group2scores_temp';
                group2class_predicted(testing_indexgroup2) = group2class_predicted(testing_indexgroup2) + 1;
                group2class_tested(testing_indexgroup2) = group2class_tested(testing_indexgroup2) + 1;
                group2class_scored(testing_indexgroup2) = group2class_scored(testing_indexgroup2) + 1;
            end
            clear treebag_temp group1class_temp group2class_temp
            sprintf('%s',strcat('run #',num2str(i),' cumulative accuracy=',num2str(mean(accuracy(1,1:i)))))
        end
        group1class = group1class./group1class_tested;
        group2class = group2class./group2class_tested;
        group1predict = group1predict./group1class_predicted;
        group2predict = group2predict./group2class_tested;
        group1scores = group1scores./group1class_scored;
        group2scores = group2scores./group2class_scored;
        final_data = all_data;  
    end
    toc
elseif holdout == 1
    for j = 1:max(size(holdout_data))
        data_to_remove = holdout_data(j).ix;
        ncomps_to_remove = max(size(data_to_remove));
        testing_data = zeros(ncomps_to_remove*2,nvars);
        testing_groups = zeros(ncomps_to_remove*2,1);
        testing_groups(1:ncomps_to_remove,1) = 0;
        testing_groups(ncomps_to_remove+1:ncomps_to_remove*2,1) = 1;
        if cross_valid == 1
            testing_indexgroup1 = data_to_remove(find(data_to_remove <= nsubs_group1));
            if isempty(testing_indexgroup1)
                group_holdout = 0;
            else
                group_holdout = 1;
            end
            testing_indexgroup2 = data_to_remove(find(data_to_remove - nsubs_group1 > 0)) - nsubs_group1;
            if isempty(testing_indexgroup2) == 0
                group_holdout = group_holdout + 2;
            end
        end
        if group_holdout == 1
            testing_indexgroup1 = data_to_remove;
            index_group1 = true(1, size(group1_data, 1));
            index_group1(data_to_remove.') = false;
            group1_data_holdout = group1_data(index_group1, :);
            nsubs_group1_holdout = size(group1_data_holdout,1);
            nsubs_group2_holdout = nsubs_group2;
            group2_data_holdout = group2_data;
            matchsubs_group1_holdout = nsubs_group1_holdout;
            matchsubs_group2_holdout = matchsubs_group2;
        elseif group_holdout == 2
            testing_indexgroup2 = data_to_remove;
            index_group2 = true(1, size(group2_data, 1));
            index_group2(data_to_remove.') = false;
            group2_data_holdout = group2_data(index_group2, :);
            nsubs_group2_holdout = size(group2_data_holdout,1);
            nsubs_group1_holdout = nsubs_group1;
            group1_data_holdout = group1_data; 
            matchsubs_group2_holdout = nsubs_group2_holdout;
            matchsubs_group1_holdout = matchsubs_group1;
        elseif group_holdout == 3
            index_group1 = true(1, size(group1_data, 1));
            index_group1(testing_indexgroup1.') = false;
            group1_data_holdout = group1_data(index_group1, :);
            nsubs_group1_holdout = size(group1_data_holdout,1);
            matchsubs_group1_holdout = nsubs_group1_holdout;
            index_group2 = true(1, size(group2_data, 1));
            index_group2(testing_indexgroup2.') = false;
            group2_data_holdout = group2_data(index_group2, :);
            nsubs_group2_holdout = size(group2_data_holdout,1);
            matchsubs_group2_holdout = nsubs_group2_holdout;           
        end
        if independent_outcomes == 0
            learning_groups = zeros(matchsubs_group1_holdout + matchsubs_group2_holdout - ncomps_to_remove,1);            
            learning_groups(1:matchsubs_group1_holdout-ncomps_to_remove,1) = 0;
            learning_groups(matchsubs_group1_holdout-ncomps_to_remove+1:matchsubs_group1_holdout + matchsubs_group2_holdout - ncomps_to_remove,1) = 1;
        else
            learning_groups = zeros(matchsubs_group1_holdout + matchsubs_group2_holdout - ncomps_to_remove,1);
            learning_groups(1:matchsubs_group1_holdout-ncomps_to_remove,1) = group1_outcome(index_group1);
        end
            learning_data = zeros(matchsubs_group1_holdout + matchsubs_group2_holdout - ncomps_to_remove,nvars);            
        tic
        if nsubs_group1_holdout + nsubs_group2_holdout <= proximity_sub_limit
            all_data = group1_data;
            all_data(end+1:end+nsubs_group2,:) = group2_data;
            for i = 1:nreps
                rng('shuffle');
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
                    categorical_vectors_to_use = categorical_vector(trimmed_features);                                    
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
                    testing_indexgroup2 = group2_subjects(matchsubs_group2_holdout-ncomps_to_remove+1:matchsubs_group2_holdout);
                else
                    learning_data(1:matchsubs_group1_holdout-ncomps_to_remove,:) = resample_group1_data(matchsubs_group1_holdout - ncomps_to_remove,:);
                    learning_data(matchsubs_group1_holdout-ncomps_to_remove+1:matchsubs_group1_holdout+matchsubs_group2_holdout - ncomps_to_remove,:) = resample_group2_data;
                    testing_indexgroup1 = group1_subjects(matchsubs_group1_holdout-ncomps_to_remove+1:matchsubs_group1_holdout);
                    testing_data(1:ncomps_to_remove,:) = resample_group1_data(matchsubs_group1_holdout-ncomps_to_remove+1:matchsubs_group1_holdout,:);
                    testing_data(ncomps_to_remove+1:ncomps_to_remove*2,:) = group2_data(data_to_remove,trimmed_features);
                end
                if dim_reduce
                    training_data = ModuleFeatureExtractor('InputData',training_data,'Modules',modules,'DimType',dim_type,'NumComponents',num_components);
                    testing_data = ModuleFeatureExtractor('InputData',testing_data,'Modules',modules,'DimType',dim_type,'NumComponents',num_components);
                    categorical_vectors_to_use = logical(zeros(size(training_data,2)));
                    dim_data = zeros(size(training_data,1)+size(testing_data,1),size(testing_data,2));
                    dim_data(training_selection,:) = training_data;
                    dim_data(testing_selection,:) = testing_data;
                end
                if (estimate_tree_predictors)
                    npredictors_used = TestTreeBags(learning_groups,learning_data,[],[],ntrees,'EstimatePredictorsToSample',0,0,categorical_vectors_to_use,'npredictors',npredictors,'surrogate',surrogate, 'Prior', prior);
                else
                    npredictors_used = npredictors;
                end             
                if (estimate_trees)
                    [ntrees_est,~,outofbag_error_temp] = TestTreeBags(learning_groups,learning_data,[],[],ntrees,'estimate_trees',0,0,categorical_vectors_to_use,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior);
                    size(outofbag_error_temp)
                    outofbag_error(i,1:length(outofbag_error_temp),j) = outofbag_error_temp;
                else
                    ntrees_est = ntrees;
                end
                if (estimate_predictors)
                    [accuracy(:,i,j),treebag_temp,outofbag_error(i,:,j),outofbag_varimp(i,:,j),group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validationPlusOOB',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
                elseif (OOB_error_on)
                    [accuracy(:,i),treebag_temp,outofbag_error(i,:),~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation_OOBerror',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);                
                elseif (weight_forest)
                    [tree_weights,treebag_temp] = TestTreeBags(learning_groups,learning_data,[],[],ntrees_est,'weight_trees',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior);
                    [accuracy(:,i,j),~,~,~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags([],[], testing_groups, testing_data,ntrees_est,'validation_weighted',treebag_temp,tree_weights,categorical_vectors_to_use,class_method,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);            
                elseif (estimate_trees)
                    [accuracy(:,i,j),treebag_temp,~,~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
                else
                    [accuracy(:,i,j),treebag_temp,outofbag_error(i,:,j),outofbag_varimp(i,:,j),group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
                end  
                proxmat{i,j} = proximity(treebag_temp.compact,all_data);
                features_used = features_used + CollateUsedFeatures(treebag_temp.Trees,nvars);
                if disable_treebag == 0
                    treebag{i,1,j} = treebag_temp;
                end
                if testing_indexgroup1 > 0
                    group1class(testing_indexgroup1) = group1class(testing_indexgroup1) + group1class_temp;
                    group1predict(testing_indexgroup1) = group1predict(testing_indexgroup1) + group1predict_temp;
                    group1scores(testing_indexgroup1) = group1scores(testing_indexgroup1) + group1scores_temp';
                    group1class_predicted(testing_indexgroup1) = group1class_predicted(testing_indexgroup1) + 1;
                    group1class_tested(testing_indexgroup1) = group1class_tested(testing_indexgroup1) + 1;
                    group1class_scored(testing_indexgroup1) = group1class_scored(testing_indexgroup1) + 1;
                end
                if testing_indexgroup2 > 0
                    group2class(testing_indexgroup2) = group2class(testing_indexgroup2) + group2class_temp;
                    group2predict(testing_indexgroup2) = group2predict(testing_indexgroup2) + group2predict_temp;
                    group2scores(testing_indexgroup2) = group2predict(testing_indexgroup2) + group2scores_temp';
                    group2class_predicted(testing_indexgroup2) = group2class_predicted(testing_indexgroup2) + 1;
                    group2class_tested(testing_indexgroup2) = group2class_tested(testing_indexgroup2) + 1;
                    group2class_scored(testing_indexgroup2) = group2class_scored(testing_indexgroup2) + 1;
                end
                clear treebag_temp group1class_temp group2class_temp
                sprintf('%s',strcat('run #',num2str(i),' cumulative accuracy=',num2str(mean(accuracy(1,1:i)))))
            end
            group1class = group1class./group1class_tested;
            group2class = group2class./group2class_tested;
            group1predict = group1predict./group1class_predicted;
            group2predict = group2predict./group2class_tested;
            group1scores = group1scores./group1class_scored;
            group2scores = group2scores./group2class_scored;
            final_data = all_data; 
        else
            for i = 1:nreps
                rng('shuffle');
                group1_subjects = randperm(nsubs_group1_holdout,matchsubs_group1_holdout);
                group2_subjects = randperm(nsubs_group2_holdout,matchsubs_group2_holdout);
                resample_group1_data = group1_data_holdout(group1_subjects,:);
                resample_group2_data = group2_data_holdout(group2_subjects,:);
                if (trim_features)
                    [~,~,trimmed_features] = KSFeatureTrimmer(resample_group1_data(1:floor(matchsubs_group1_holdout*datasplit),:),resample_group2_data(1:floor(matchsubs_group2_holdout*datasplit),:),nfeatures);
                    resample_group1_data = group1_data_holdout(group1_subjects,trimmed_features);
                    resample_group2_data = group2_data_holdout(group2_subjects,trimmed_features);
                    trimmed_feature_sets(i,:,j) = trimmed_features;
                    categorical_vectors_to_use = categorical_vector(trimmed_features);                                                        
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
                    all_data = group1_data(sort([group1_subjects data_to_remove.']),trimmed_features); 
                    all_data(end+1:end+matchsubs_group2_holdout,:) = group2_data(sort(group2_subjects),trimmed_features); 
                    learning_data(1:matchsubs_group1_holdout,:) = resample_group1_data;
                    learning_data(matchsubs_group1_holdout+1:matchsubs_group1_holdout+matchsubs_group2_holdout - ncomps_to_remove,:) = resample_group2_data(1:matchsubs_group2_holdout - ncomps_to_remove,:);
                    testing_data(1:ncomps_to_remove,:) = group1_data(data_to_remove,trimmed_features);
                    testing_data(ncomps_to_remove+1:ncomps_to_remove*2,:) = resample_group2_data(matchsubs_group2_holdout-ncomps_to_remove+1:matchsubs_group2_holdout,:);
                    testing_indexgroup2 = group2_subjects(matchsubs_group2_holdout-ncomps_to_remove+1:matchsubs_group2_holdout);
                else
                    all_data = group1_data(sort(group1_subjects),trimmed_features); 
                    all_data(end+1:end+matchsubs_group2_holdout+ncomps_to_remove,:) = group2_data(sort([group2_subjects data_to_remove]),trimmed_features);                     
                    learning_data(1:matchsubs_group1_holdout-ncomps_to_remove,:) = resample_group1_data(matchsubs_group1_holdout - ncomps_to_remove,:);
                    learning_data(matchsubs_group1_holdout-ncomps_to_remove+1:matchsubs_group1_holdout+matchsubs_group2_holdout - ncomps_to_remove,:) = resample_group2_data;
                    testing_indexgroup1 = group1_subjects(matchsubs_group1_holdout-ncomps_to_remove+1:matchsubs_group1_holdout);
                    testing_data(1:ncomps_to_remove,:) = resample_group1_data(matchsubs_group1_holdout-ncomps_to_remove+1:matchsubs_group1_holdout,:);
                    testing_data(ncomps_to_remove+1:ncomps_to_remove*2,:) = group2_data(data_to_remove,trimmed_features);
                end
                if dim_reduce
                    training_data = ModuleFeatureExtractor('InputData',training_data,'Modules',modules,'DimType',dim_type,'NumComponents',num_components);
                    testing_data = ModuleFeatureExtractor('InputData',testing_data,'Modules',modules,'DimType',dim_type,'NumComponents',num_components);
                    categorical_vectors_to_use = logical(zeros(size(training_data,2)));
                    dim_data = zeros(size(training_data,1)+size(testing_data,1),size(testing_data,2));
                    dim_data(training_selection,:) = training_data;
                    dim_data(testing_selection,:) = testing_data;
                end
                if (estimate_tree_predictors)
                    npredictors_used = TestTreeBags(learning_groups,learning_data,[],[],ntrees,'EstimatePredictorsToSample',0,0,categorical_vectors_to_use,'npredictors',npredictors,'surrogate',surrogate, 'Prior', prior);
                else
                    npredictors_used = npredictors;
                end        
                if (estimate_trees)
                    [ntrees_est,~,outofbag_error_temp] = TestTreeBags(learning_groups,learning_data,[],[],ntrees,'estimate_trees',0,0,categorical_vectors_to_use,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior);
                    size(outofbag_error_temp)
                    outofbag_error(i,1:length(outofbag_error_temp),j) = outofbag_error_temp;
                else
                    ntrees_est = ntrees;
                end
                if (estimate_predictors)
                    [accuracy(:,i,j),treebag_temp,outofbag_error(i,:,j),outofbag_varimp(i,:,j),group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validationPlusOOB',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
                elseif (OOB_error_on)
                    [accuracy(:,i),treebag_temp,outofbag_error(i,:),~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation_OOBerror',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);                
                elseif (weight_forest)
                    [tree_weights,treebag_temp] = TestTreeBags(learning_groups,learning_data,[],[],ntrees_est,'weight_trees',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior);
                    [accuracy(:,i,j),~,~,~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags([],[], testing_groups, testing_data,ntrees_est,'validation_weighted',treebag_temp,tree_weights,categorical_vectors_to_use,class_method,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);            
                elseif (estimate_trees)
                    [accuracy(:,i,j),treebag_temp,~,~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
                else
                    [accuracy(:,i,j),treebag_temp,outofbag_error(i,:,j),outofbag_varimp(i,:,j),group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees_est,'validation',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
                end  
                proxmat{i,j} = proximity(treebag_temp.compact,all_data);
                features_used = features_used + CollateUsedFeatures(treebag_temp.Trees,nvars);
                if disable_treebag == 0
                    treebag{i,1,j} = treebag_temp;
                end
                if testing_indexgroup1 > 0
                    group1class(testing_indexgroup1) = group1class(testing_indexgroup1) + group1class_temp;
                    group1predict(testing_indexgroup1) = group1predict(testing_indexgroup1) + group1predict_temp;
                    group1scores(testing_indexgroup1) = group1scores(testing_indexgroup1) + group1scores_temp';
                    group1class_predicted(testing_indexgroup1) = group1class_predicted(testing_indexgroup1) + 1;
                    group1class_tested(testing_indexgroup1) = group1class_tested(testing_indexgroup1) + 1;
                    group1class_scored(testing_indexgroup1) = group1class_scored(testing_indexgroup1) + 1;
                end
                if testing_indexgroup2 > 0
                    group2class(testing_indexgroup2) = group2class(testing_indexgroup2) + group2class_temp;
                    group2predict(testing_indexgroup2) = group2predict(testing_indexgroup2) + group2predict_temp;
                    group2scores(testing_indexgroup2) = group2predict(testing_indexgroup2) + group2scores_temp';
                    group2class_predicted(testing_indexgroup2) = group2class_predicted(testing_indexgroup2) + 1;
                    group2class_tested(testing_indexgroup2) = group2class_tested(testing_indexgroup2) + 1;
                    group2class_scored(testing_indexgroup2) = group2class_scored(testing_indexgroup2) + 1;
                end
                clear treebag_temp group1class_temp group2class_temp
                sprintf('%s',strcat('run #',num2str(i),' cumulative accuracy=',num2str(mean(accuracy(1,1:i)))))
            end
            group1class = group1class./group1class_tested;
            group2class = group2class./group2class_tested;
            group1predict = group1predict./group1class_predicted;
            group2predict = group2predict./group2class_tested;
            group1scores = group1scores./group1class_scored;
            group2scores = group2scores./group2class_scored;
            final_data = all_data; 
            end
        toc    
    end
elseif holdout==2 %WARNING cross-validate carries its own parameters and will overwrite everything else
        tic
        if independent_outcomes == 0
            group1_outcome = zeros(size(group1_data,1),1) + 1;
            group2_outcome = ones(size(group2_data,1),1) + 1;
        end
        if matchgroups
            all_data_start = group1_data;
            all_data_start(end+1:end+size(group2_data,1),:) = group2_data; 
            all_outcomes_start = group1_outcome;
            all_outcomes_start(end+1:end+size(group2_data,1),1) = group2_outcome;
            all_outcomes_start_mask = true(length(all_outcomes_start),1);
            group1scores = zeros(nsubs_group1,length(unique(all_outcomes_start)));
            group2scores = zeros(nsubs_group2,length(unique(all_outcomes_start)));
            group2class_scored = zeros(nsubs_group2,length(unique(all_outcomes_start)));
            group1class_scored = zeros(nsubs_group1,length(unique(all_outcomes_start)));        
            if dim_reduce
                dim_data_start = ModuleFeatureExtractor('InputData',all_data_start,'Modules',modules,'DimType',dim_type,'NumComponents',num_components);
            end
        else
            if regression==0
                all_outcomes = group1_outcome;
                all_outcomes(end+1:end+size(group2_data,1),1) = group2_outcome;
                final_outcomes = all_outcomes;
                size(all_outcomes)
                group1scores = zeros(nsubs_group1,length(unique(all_outcomes)));
                group2scores = zeros(nsubs_group2,length(unique(all_outcomes)));
                group2class_scored = zeros(nsubs_group2,length(unique(all_outcomes)));
                group1class_scored = zeros(nsubs_group1,length(unique(all_outcomes)));
            end 		
        end
        if unsupervised
            group2_data = group1_data;
            nsubs_group1 = size(group1_data,1);
            nsubs_group2 = nsubs_group1;
            rng('shuffle');
            all_vector = 1:nsubs_group2;
            group1_outcome = ones(nsubs_group1,1);
            group2_outcome = ones(nsubs_group2,1) + 1;
            group2_data_temp = zeros(size(group2_data,1),size(group2_data,2));
            group2_data_temp(:,1) = group2_data(:,1);
            for subject_index = 1:nsubs_group2
                subject_vector = all_vector(find(all_vector ~= subject_index));
                for feature_index = 2:nvars
                    new_subject = subject_vector(randi(length(subject_vector)));
                    subject_vector = subject_vector(find(subject_vector ~= new_subject));
                    group2_data_temp(subject_index,feature_index) = group2_data(new_subject,feature_index);
                    if isempty(subject_vector)
                        sprintf('%s','number of features greater than number of subjects, unsupervised alogrithm will be partially supervised');
                        subject_vector = all_vector(find(all_vector ~= subject_index));
                    end
                end
            end
           group2_data = group2_data_temp;            
        end
        proxmat = cell(nreps*nfolds,1);
        prox_count = 0;
        all_data = group1_data;
        all_data(end+1:end+size(group2_data,1),:) = group2_data; 
        group1_subjects = 1:size(group1_data,1);
        group2_subjects = 1:size(group2_data,1);
        group1_allsubs = group1_subjects;
        group2_allsubs = group2_subjects;        
        all_outcomes = group1_outcome;
        all_outcomes(end+1:end+size(group2_data,1),1) = group2_outcome;
        final_outcomes = all_outcomes;
        if regression
            accuracy = zeros(3,nfolds,nreps,2);
        else
            accuracy = zeros(length(unique(all_outcomes))+1,nfolds,nreps,2);
        end        
    for i = 1:nreps
        rng('Shuffle');
        if matchgroups
            unique_outcomes = unique(all_outcomes_start);
            nsubs_by_outcome = zeros(length(unique_outcomes),1);
            all_data = group1_data(1,:);
            all_outcomes = group1_outcome(1);
            all_outcomes_mask = all_outcomes_start_mask;
            all_subject_index = 1;
            for curr_outcome = 1:length(unique_outcomes)
                nsubs_by_outcome(curr_outcome) = length(find(all_outcomes_start == unique_outcomes(curr_outcome)));
            end
            smallest_outcome = min(nsubs_by_outcome);
            for curr_outcome = 1:length(unique_outcomes)
                subject_index = find(all_outcomes_start == unique_outcomes(curr_outcome));
                subs_to_use = subject_index(randperm(nsubs_by_outcome(curr_outcome),smallest_outcome));
                all_outcomes_mask(subs_to_use) = false;
                all_data(end:end-1+length(subs_to_use),:) = all_data_start(subs_to_use,:);
                all_outcomes(end:end-1+length(subs_to_use),:) = all_outcomes_start(subs_to_use,:);
                all_subject_index(end:end-1+length(subs_to_use),1) = subs_to_use;
            end
            nsubs = size(all_data,1);
            group2_data = all_data(floor(nsubs/2)+1:end,:);
            group1_data = all_data(1:floor(nsubs/2),:);
            group2_outcome = all_outcomes(floor(nsubs/2)+1:end);
            group1_outcome = all_outcomes(1:floor(nsubs/2));
            size(group1_allsubs)
            size(group1_data)
            size(group2_data)
            size(all_outcomes)
            group1_subjects = all_subject_index(all_subject_index <= size(group1_allsubs,2));
            group2_subjects = all_subject_index(all_subject_index > size(group1_allsubs,2)) - size(group1_allsubs,2);
        end        
        permuted_outcomes = all_outcomes(randperm(length(all_outcomes),length(all_outcomes)));
        folds = cvpartition(all_outcomes,'KFold',nfolds);
        for curr_fold = 1:nfolds
            prox_count = prox_count + 1;
            testing_selection = test(folds,curr_fold);
            training_selection = training(folds,curr_fold);
            training_data = all_data(training_selection,:);
            testing_data = all_data(testing_selection,:);
            training_outcomes = all_outcomes(training_selection,:);
            training_perm_outcomes = permuted_outcomes(training_selection,:);
            test_outcomes = all_outcomes(testing_selection,:);
            test_perm_outcomes = permuted_outcomes(testing_selection,:);
            testing_indexgroup1 = group1_subjects(testing_selection(1:length(group1_subjects)));
            if isempty(testing_indexgroup1)
                testing_indexgroup1 = 0;
            end
            testing_indexgroup2 = group2_subjects(testing_selection(length(group1_subjects)+1:end));
            if isempty(testing_indexgroup2)
                testing_indexgroup2 = 0;
            end
            if (trim_features)
                [~,~,trimmed_features] = KSFeatureTrimmer(all_data,test_outcomes,nfeatures);
                trimmed_feature_sets(i,:) = trimmed_features;
                all_data = all_data(:,trimmed_features);
                categorical_vectors_to_use = categorical_vector(trimmed_features);
            end
            if dim_reduce
                training_data = ModuleFeatureExtractor('InputData',training_data,'Modules',modules,'DimType',dim_type,'NumComponents',num_components);
                testing_data = ModuleFeatureExtractor('InputData',testing_data,'Modules',modules,'DimType',dim_type,'NumComponents',num_components);
                categorical_vectors_to_use = logical(zeros(size(training_data,2)));
                dim_data = zeros(size(training_data,1)+size(testing_data,1),size(testing_data,2));
                dim_data(training_selection,:) = training_data;
                dim_data(testing_selection,:) = testing_data;
            end
            if (estimate_tree_predictors)
                npredictors_used = TestTreeBags(training_outcomes,training_data,[],[],ntrees,'EstimatePredictorsToSample',0,0,categorical_vectors_to_use,'npredictors',npredictors,'surrogate',surrogate, 'Prior', prior);
            else
                npredictors_used = npredictors;
            end            
            if (estimate_trees)
                [ntrees_est,~,outofbag_error_temp] = TestTreeBags(training_outcomes,training_data,[],[],ntrees,'estimate_trees',0,0,categorical_vectors_to_use,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior);
                size(outofbag_error_temp)
                outofbag_error(i,1:length(outofbag_error_temp)) = outofbag_error_temp;
            else
                ntrees_est = ntrees;
            end
            if (estimate_predictors)
                [accuracy(:,curr_fold,i,1),treebag_temp,outofbag_error(i,:),outofbag_varimp(i,:),group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(training_outcomes, training_data, test_outcomes, testing_data, ntrees_est,'validationPlusOOB',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
                accuracy(:,curr_fold,i,2) = TestTreeBags(training_perm_outcomes, training_data, test_perm_outcomes, testing_data, ntrees_est,'validationPlusOOB',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);           
            elseif (OOB_error_on)
                [accuracy(:,curr_fold,i,1),treebag_temp,outofbag_error(i,:),~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(training_outcomes, training_data, test_outcomes, testing_data,ntrees_est,'validation_OOBerror',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);                
                accuracy(:,curr_fold,i,2) = TestTreeBags(training_perm_outcomes, training_data, test_perm_outcomes, testing_data,ntrees_est,'validation_OOBerror',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);                            
            elseif (weight_forest)
                [tree_weights,treebag_temp] = TestTreeBags(training_outcomes,training_data,[],[],ntrees_est,'weight_trees',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior);
                [accuracy(:,curr_fold,i,1),~,~,~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags([],[], test_outcomes, testing_data,ntrees_est,'validation_weighted',treebag_temp,tree_weights,categorical_vectors_to_use,class_method,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);            
                [tree_weights,treebag_temp] = TestTreeBags(training_perm_outcomes,training_data,[],[],ntrees_est,'weight_trees',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior);
                accuracy(:,curr_fold,i,2) = TestTreeBags([],[], test_perm_outcomes, testing_data,ntrees_est,'validation_weighted',treebag_temp,tree_weights,categorical_vectors_to_use,class_method,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);            
            elseif (estimate_trees)
                [accuracy(:,curr_fold,i,1),treebag_temp,~,~,group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(training_outcomes, training_data, test_outcomes, testing_data,ntrees_est,'validation',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
                accuracy(:,curr_fold,i,2) = TestTreeBags(training_perm_outcomes, training_data, test_perm_outcomes, testing_data,ntrees_est,'validation',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
            else
                [accuracy(:,curr_fold,i,1),treebag_temp,outofbag_error(i,:),outofbag_varimp(i,:),group1class_temp,group2class_temp,group1predict_temp,group2predict_temp,group1scores_temp,group2scores_temp] = TestTreeBags(training_outcomes, training_data, test_outcomes, testing_data,ntrees_est,'validation',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
                accuracy(:,curr_fold,i,2) = TestTreeBags(training_perm_outcomes, training_data, test_perm_outcomes, testing_data,ntrees_est,'validation',0,0,categorical_vectors_to_use,class_method,'npredictors',npredictors_used,'surrogate',surrogate, 'Prior', prior,'group1class',testing_indexgroup1,'group2class',testing_indexgroup2);
            end          
            if (trim_features)
                all_data = all_data(:,trimmed_features);
            end
            if dim_reduce
                if matchgroups
                    proxmat{prox_count,1} = proximity(treebag_temp.compact,dim_data_start);
                else
                    proxmat{prox_count,1} = proximity(treebag_temp.compact,dim_data);
                end
            else
                if matchgroups
                    proxmat{prox_count,1} = proximity(treebag_temp.compact,all_data_start);
                else
                    proxmat{prox_count,1} = proximity(treebag_temp.compact,all_data);                
                end
            end
            features_used = features_used + CollateUsedFeatures(treebag_temp.Trees,nvars);
            if disable_treebag == 0
                treebag{i,1} = treebag_temp;
            end
            if testing_indexgroup1 > 0
                testing_indexgroup1
                size(group1scores)
                size(group1_allsubs)
                size(group1scores_temp)
                group1class(testing_indexgroup1) = group1class(testing_indexgroup1) + group1class_temp;
                group1predict(testing_indexgroup1) = group1predict(testing_indexgroup1) + group1predict_temp;
                if regression == 0
                    group1scores(testing_indexgroup1,:) = group1scores(testing_indexgroup1,:) + group1scores_temp;
                end
                group1class_predicted(testing_indexgroup1) = group1class_predicted(testing_indexgroup1) + 1;
                group1class_tested(testing_indexgroup1) = group1class_tested(testing_indexgroup1) + 1;
                group1class_scored(testing_indexgroup1,:) = group1class_scored(testing_indexgroup1,:) + 1;
            end
            if testing_indexgroup2 > 0
                testing_indexgroup2
                size(group2scores)
                size(group2_allsubs)
                size(group2scores_temp)
                group2class(testing_indexgroup2) = group2class(testing_indexgroup2) + group2class_temp;
                group2predict(testing_indexgroup2) = group2predict(testing_indexgroup2) + group2predict_temp;
                if regression == 0
                    group2scores(testing_indexgroup2,:) = group2scores(testing_indexgroup2,:) + group2scores_temp;
                end
                group2class_predicted(testing_indexgroup2) = group2class_predicted(testing_indexgroup2) + 1;
                group2class_tested(testing_indexgroup2) = group2class_tested(testing_indexgroup2) + 1;
                group2class_scored(testing_indexgroup2,:) = group2class_scored(testing_indexgroup2,:) + 1;
            end
                clear treebag_temp group1class_temp group2class_temp
                sprintf('%s',strcat('run #',num2str(i),' cumulative accuracy=',num2str(mean(accuracy(1,1:curr_fold,i,1)))))
                sprintf('%s',strcat('run #',num2str(i),' cumulative null accuracy=',num2str(mean(accuracy(1,1:curr_fold,i,2)))))
        end
    end
    group1class = group1class./group1class_tested;
    group2class = group2class./group2class_tested;
    group1predict = group1predict./group1class_predicted;
    group2predict = group2predict./group2class_tested;
    if regression == 0
        group1scores = group1scores./group1class_scored;
        group2scores = group2scores./group2class_scored;
    end
    if matchgroups
        final_data = all_data_start;
        group1_subjects = group1_allsubs;
        group2_subjects = group2_allsubs;
    else
        final_data = all_data;
    end
toc             
end
end
