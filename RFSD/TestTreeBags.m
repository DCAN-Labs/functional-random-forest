function [accuracy,treebag,outofbag_error,outofbag_varimp,group1class,group2class,group1predict,group2predict,group1scores,group2scores] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees,type,treebag,treeweights,categorical_vector,varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if exist('type','var') == 0
    type = 'validationPlusOOB';
end
if exist('treeweights','var') == 0
    treeweights = 0;
end
if exist('treebag','var') == 0
    treebag = 0;
end
numpredictors = 0;
surrogate = 'off';
prior = 'Empirical';
testing_indexgroup1 = 0;
testing_indexgroup2 = 0;
ngroup1_substested = 0;
ngroup2_substested = 0;
group1class = 0;
group2class = 0;
group1predict = 0;
group2predict = 0;
group1scores = 0;
group2scores = 0;
class_method = 'classification';
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
            if ischar(varargin{i}) == 1 || max(size(varargin{i})) == 1
                switch(varargin{i})
                    case('npredictors')
                        numpredictors = varargin{i+1};
                    case('Surrogate')
                        surrogate = varargin{i+1};
                    case('Prior')
                        prior = varargin{i+1};
                    case('group1class')
                        testing_indexgroup1 = varargin{i+1};
                        if testing_indexgroup1 > 0
                            ngroup1_substested = max(size(testing_indexgroup1));
                            group1class = zeros(ngroup1_substested,1);
                            group1predict = zeros(ngroup1_substested,1);
                            group1scores = zeros(ngroup1_substested,length(unique(testing_groups)));
                        end
                    case('group2class')
                        testing_indexgroup2 = varargin{i+1};
                        if testing_indexgroup2 > 0
                            ngroup2_substested = max(size(testing_indexgroup2));
                            group2class = zeros(ngroup2_substested,1);
                            group2predict = zeros(ngroup2_substested,1);
                        end
                    case('regression')
                        class_method = 'regression';
                end
            end
        end
    end
end
if class_method == 'classification'
    group1scores = zeros(ngroup1_substested,length(unique(testing_groups)));
    group2scores = zeros(ngroup2_substested,length(unique(testing_groups)));
end
if numpredictors == 0
    numpredictors = round(sqrt(size(learning_data,2)));
end
switch(type)
    case('estimate_trees')
        initial_trees = 50; %%change if you want to examine smaller numbers, generally at least 50 trees will be needed for most weak classifiers
        tree_step = 10; %%change if you want to examine finer numbers -- lower numbers will slow the function
        if strcmp(class_method,'regression')
            treebag = TreeBagger(initial_trees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','on','NVarToSample',numpredictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate,'Method',class_method);        
        else
            treebag = TreeBagger(initial_trees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','on','NVarToSample',numpredictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate,'Prior', prior,'Method',class_method);
        end
        optimize = 0;
        outofbag_error_first = oobError(treebag);
        outofbag_error_first = outofbag_error_first(end);
        final_trees = initial_trees + tree_step;
        while final_trees <= ntrees && optimize == 0
            treebag = growTrees(treebag,tree_step);
            outofbag_error_second = oobError(treebag);
            outofbag_error_second = outofbag_error_second(end);
            if abs(outofbag_error_second - outofbag_error_first) < 0.001
                optimize = 1;
                accuracy = final_trees - tree_step;
            else
                final_trees = final_trees + tree_step;
                outofbag_error_first = outofbag_error_second;
            end
        end
        if optimize == 0
            accuracy = ntrees;
            sprintf('%s',strcat('Optimization algorithm exceeded tree limit. Number of trees: #',num2str(accuracy)))
        else
            sprintf('%s',strcat('Optimization found! Number of trees: #',num2str(accuracy))) 
        end
        outofbag_error = oobError(treebag);
    case('weight_trees')
        if strcmp(class_method,'regression')
            treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','off','NVarToSample',numpredictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate,'Method',class_method);       
        else
            treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','off','NVarToSample',numpredictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate,'Prior',prior,'Method',class_method);
        end
        accuracy = zeros(ntrees,1);
        for i = 1:ntrees
            prediction_classes = str2num(cell2mat(predict(treebag,treebag.X,'Trees',i)));
            accurate_classes = learning_groups == prediction_classes;
            accuracy(i,1) = var(fitdist(double(accurate_classes),'Binomial'));
        end
    case('validation')
        ngroups_index = union(unique(testing_groups),unique(learning_groups));
        ngroups = max(size(ngroups_index));
        if strcmp(class_method,'regression')
            treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','off','NVarToSample',numpredictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate,'Method',class_method);            
        else
            treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','off','NVarToSample',numpredictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate,'Prior',prior,'Method',class_method);
        end
        outofbag_error = NaN;
        outofbag_varimp = NaN;
        if strcmp(varargin{1},'regression')
            [predicted_classes_new,predicted_scores_new] = predict(treebag,testing_data);
            accuracy = zeros(3,1);
            accuracy_prediction = abs(predicted_classes_new - testing_groups);
            temp_sub_index = 0;
            for i = 1:ngroup1_substested
                temp_sub_index = temp_sub_index + 1;
                group1class(i) = abs(predicted_classes_new(temp_sub_index) - testing_groups(temp_sub_index));
                group1predict(i) = predicted_classes_new(temp_sub_index);
                group1scores(i) = predicted_scores_new(temp_sub_index);
            end
            for i = 1:ngroup2_substested
                temp_sub_index = temp_sub_index + 1;
                group2class(i) = abs(predicted_classes_new(temp_sub_index) - testing_groups(temp_sub_index));
                group2predict(i) = predicted_classes_new(temp_sub_index);
                group2scores(i) = predicted_scores_new(temp_sub_index);
            end
            accuracy(1,1) = mean(accuracy_prediction);
            accuracy(2,1) = corr(predicted_classes_new,testing_groups);
            N = max(max(size(testing_groups)));
            mean_all = (accuracy(1,1)+mean(testing_groups))/2;
            nx1=0;
            nx2=0;
            nxpooled=0;
            for i = 1:N
                nx1=nx1+(testing_groups(i) - mean_all)^2;
                nx2=nx2+(predicted_classes_new(i) - mean_all)^2;
                nxpooled = nxpooled + ((predicted_classes_new(i) - mean_all)*(testing_groups(i) - mean_all));
            end
            s_squared = (nx1+nx2)/((2*N)-1);
            accuracy(3,1) = nxpooled/(N*s_squared);
        else
           [predicted_classes,predicted_scores] = predict(treebag,testing_data);
           size(predicted_scores)
           predicted_classes = str2num(cell2mat(predicted_classes));
            accuracy_prediction = predicted_classes == testing_groups;
            temp_sub_index = 0;
            for i = 1:ngroup1_substested
                temp_sub_index = temp_sub_index + 1;
                group1class(i) = accuracy_prediction(temp_sub_index);
                group1predict(i) = predicted_classes(temp_sub_index);
                group1scores(i,:) = predicted_scores(temp_sub_index,:);
            end
            for i = 1:ngroup2_substested
                temp_sub_index = temp_sub_index + 1;
                group2class(i) = accuracy_prediction(temp_sub_index);
                group2predict(i) = predicted_classes(temp_sub_index);
                group2scores(i,:) = predicted_scores(temp_sub_index,:);
            end
            accuracy = zeros(ngroups+1,1);
%            accuracy(1,1) = size(find(accuracy_prediction == ngroups_index(1)),1)/size(testing_groups,1);
            for n = 1:ngroups
                accuracy(n+1,1) = size(find(accuracy_prediction(testing_groups == ngroups_index(n)) == 1),1)/size(find(testing_groups == ngroups_index(n)),1);
                accuracy(1,1) = accuracy(1,1) + size(find(accuracy_prediction(testing_groups == ngroups_index(n)) == 1),1);
            end
            accuracy(1,1) = accuracy(1,1)/size(testing_groups,1);
        end
    case('validation_weighted')
        ngroups_index = union(unique(testing_groups),unique(learning_groups));
        ngroups = max(size(ngroups_index));        
        outofbag_error = NaN;
        outofbag_varimp = NaN;
        if strcmp(varargin{1},'regression')
            [predicted_classes_new,predicted_scores_new] = predict(treebag,testing_data,'TreeWeights',treeweights);
            accuracy = zeros(3,1);
            temp_sub_index = 0;
			if testing_indexgroup1 ~= 0
            	for i = 1:ngroup1_substested
                	temp_sub_index = temp_sub_index + 1;
                	group1class(i) = abs(predicted_classes_new(temp_sub_index) - testing_groups(temp_sub_index));
                    group1predict(i) = predicted_classes_new(temp_sub_index);
                    group1scores(i) = predicted_scores_new(temp_sub_index);
            	end
			else
				group1class = NaN;
			end
			if testing_indexgroup2 ~= 0
            	for i = 1:ngroup2_substested
                	temp_sub_index = temp_sub_index + 1;
                	group2class(i) = abs(predicted_classes_new(temp_sub_index) - testing_groups(temp_sub_index));
                    group2predict(i) = predicted_classes_new(temp_sub_index);
                    group2scores(i) = predicted_scores_new(temp_sub_index);
            	end            
			else
				group2class = NaN;
			end       
            accuracy_prediction = abs(predicted_classes_new - testing_groups);
            accuracy(1,1) = mean(accuracy_prediction);
            accuracy(2,1) = corr(predicted_classes_new,testing_groups);
            N = max(max(size(testing_groups)));
            mean_all = (accuracy(1,1)+mean(testing_groups))/2;
            nx1=0;
            nx2=0;
            nxpooled=0;
            for i = 1:N
                nx1=nx1+(testing_groups(i) - mean_all)^2;
                nx2=nx2+(predicted_classes_new(i) - mean_all)^2;
                nxpooled = nxpooled + ((predicted_classes_new(i) - mean_all)*(testing_groups(i) - mean_all));
            end
            s_squared = (nx1+nx2)/((2*N)-1);
            accuracy(3,1) = nxpooled/(N*s_squared);
        else
            [predicted_classes,predicted_scores] =predict(treebag,testing_data,'TreeWeights',treeweights);
            predicted_classes = str2num(cell2mat(predicted_classes));
            accuracy_prediction = predicted_classes == testing_groups;
            temp_sub_index = 0;
			if testing_indexgroup1 ~= 0
            	for i = 1:ngroup1_substested
                	temp_sub_index = temp_sub_index + 1;
                	group1class(i) = accuracy_prediction(temp_sub_index);
                    group1predict(i) = predicted_classes(temp_sub_index);
                    group1scores(i) = predicted_scores(temp_sub_index);
            	end
			else
				group1class = NaN;
			end
			if testing_indexgroup2 ~= 0
            	for i = 1:ngroup2_substested
                	temp_sub_index = temp_sub_index + 1;
                	group2class(i) = accuracy_prediction(temp_sub_index);
                    group2predict(i) = predicted_classes(temp_sub_index);
                    group2scores(i) = predicted_scores(temp_sub_index);
            	end
			else
				group2class = NaN;
			end                  
            accuracy = zeros(ngroups+1,1);
%            accuracy(1,1) = size(find(accuracy_prediction == ngroups_index(1)),1)/size(testing_groups,1);
            for n = 1:ngroups
                accuracy(n+1,1) = size(find(accuracy_prediction(testing_groups == ngroups_index(n)) == 1),1)/size(find(testing_groups == ngroups_index(n)),1);
                accuracy(1,1) = accuracy(1,1) + size(find(accuracy_prediction(testing_groups == ngroups_index(n)) == 1),1);
            end
            accuracy(1,1) = accuracy(1,1)/size(testing_groups,1);
        end        
    case('validationPlusOOB')
        ngroups_index = union(unique(testing_groups),unique(learning_groups));
        ngroups = max(size(ngroups_index));
        if strcmp(class_method,'regression')
            treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','on','OOBPred','on','NVarToSample',numpredictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate,'Method',class_method);        
        else
            treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','on','OOBPred','on','NVarToSample',numpredictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate,'Prior',prior,'Method',class_method);
        end
        outofbag_error = oobError(treebag);
        outofbag_varimp = treebag.OOBPermutedPredictorDeltaError;
        if strcmp(varargin{1},'regression')
            [predicted_classes_new,predicted_scores_new] = predict(treebag,testing_data);
            accuracy = zeros(3,1);
            temp_sub_index = 0;
			if testing_indexgroup1 ~= 0
            	for i = 1:ngroup1_substested
                	temp_sub_index = temp_sub_index + 1;
                	group1class(i) = abs(predicted_classes_new(temp_sub_index) - testing_groups(temp_sub_index));
                    group1predict(i) = predicted_classes_new(temp_sub_index);
                    group1scores(i) = predicted_scores_new(temp_sub_index);
            	end
			else
				group1class = NaN;
			end
			if testing_indexgroup2 ~= 0
            	for i = 1:ngroup2_substested
                	temp_sub_index = temp_sub_index + 1;
                	group2class(i) = abs(predicted_classes_new(temp_sub_index) - testing_groups(temp_sub_index));
                    group2predict(i) = predicted_classes_new(temp_sub_index);
                    group2scores(i) = predicted_scores_new(temp_sub_index);
            	end            
			else
				group2class = NaN;
			end  
            accuracy_prediction = abs(predicted_classes_new - testing_groups);
            accuracy(1,1) = mean(accuracy_prediction);
            accuracy(2,1) = corr(predicted_classes_new,testing_groups);
            N = max(max(size(testing_groups)));
            mean_all = (accuracy(1,1)+mean(testing_groups))/2;
            nx1=0;
            nx2=0;
            nxpooled=0;
            for i = 1:N
                nx1=nx1+(testing_groups(i) - mean_all)^2;
                nx2=nx2+(predicted_classes_new(i) - mean_all)^2;
                nxpooled = nxpooled + ((predicted_classes_new(i) - mean_all)*(testing_groups(i) - mean_all));
            end
            s_squared = (nx1+nx2)/((2*N)-1);
            accuracy(3,1) = nxpooled/(N*s_squared);
        else
            [predicted_classes,predicted_scores] = predict(treebag,testing_data);
            predicted_classes = str2num(cell2mat(predicted_classes));
            accuracy_prediction = predicted_classes == testing_groups;
            temp_sub_index = 0;
			if testing_indexgroup1 ~= 0
            	for i = 1:ngroup1_substested
                	temp_sub_index = temp_sub_index + 1;
                	group1class(i) = accuracy_prediction(temp_sub_index);
                    group1predict(i) = predicted_classes(temp_sub_index);
                    group1scores(i) = predicted_scores(temp_sub_index);
            	end
			else
				group1class = NaN;
			end
			if testing_indexgroup2 ~= 0
            	for i = 1:ngroup2_substested
                	temp_sub_index = temp_sub_index + 1;
                	group2class(i) = accuracy_prediction(temp_sub_index);
                    group2predict(i) = predicted_classes(temp_sub_index);
                    group2scores(i) = predicted_scores(temp_sub_index);
            	end
			else
				group2class = NaN;
			end       
            accuracy = zeros(ngroups+1,1);
%            accuracy(1,1) = size(find(accuracy_prediction == ngroups_index(1)),1)/size(testing_groups,1);
            for n = 1:ngroups
                accuracy(n+1,1) = size(find(accuracy_prediction(testing_groups == ngroups_index(n)) == 1),1)/size(find(testing_groups == ngroups_index(n)),1);
                accuracy(1,1) = accuracy(1,1) + size(find(accuracy_prediction(testing_groups == ngroups_index(n)) == 1),1);
            end
            accuracy(1,1) = accuracy(1,1)/size(testing_groups,1);
        end
    case('validation_OOBerror')
        ngroups_index = union(unique(testing_groups),unique(learning_groups));
        ngroups = max(size(ngroups_index));
        if strcmp(class_method,'regression')
            treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','on','NVarToSample',numpredictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate,'Method',class_method);        
        else
            treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','on','NVarToSample',numpredictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate,'Prior',prior,'Method',class_method);
        end
        outofbag_error = oobError(treebag);
        outofbag_varimp = NaN;
        if strcmp(varargin{1},'regression')
            [predicted_classes_new,predicted_scores_new] = predict(treebag,testing_data);
            accuracy = zeros(3,1);
            temp_sub_index = 0;
			if testing_indexgroup1 ~= 0
            	for i = 1:ngroup1_substested
                	temp_sub_index = temp_sub_index + 1;
                	group1class(i) = abs(predicted_classes_new(temp_sub_index) - testing_groups(temp_sub_index));
                    group1predict(i) = predicted_classes_new(temp_sub_index);
                    group1scores(i) = predicted_scores_new(temp_sub_index);
            	end
			else
				group1class = NaN;
			end
			if testing_indexgroup2 ~= 0
            	for i = 1:ngroup2_substested
                	temp_sub_index = temp_sub_index + 1;
                	group2class(i) = abs(predicted_classes_new(temp_sub_index) - testing_groups(temp_sub_index));
                    group2predict(i) = predicted_classes_new(temp_sub_index);
                    group2scores(i) = predicted_scores_new(temp_sub_index);
            	end            
			else
				group2class = NaN;
			end  
            accuracy_prediction = abs(predicted_classes_new - testing_groups);
            accuracy(1,1) = mean(accuracy_prediction);
            accuracy(2,1) = corr(predicted_classes_new,testing_groups);
            N = max(max(size(testing_groups)));
            mean_all = (accuracy(1,1)+mean(testing_groups))/2;
            nx1=0;
            nx2=0;
            nxpooled=0;
            for i = 1:N
                nx1=nx1+(testing_groups(i) - mean_all)^2;
                nx2=nx2+(predicted_classes_new(i) - mean_all)^2;
                nxpooled = nxpooled + ((predicted_classes_new(i) - mean_all)*(testing_groups(i) - mean_all));
            end
            s_squared = (nx1+nx2)/((2*N)-1);
            accuracy(3,1) = nxpooled/(N*s_squared);
        else
            [predicted_classes,predicted_scores] = predict(treebag,testing_data);
            predicted_classes = str2num(cell2mat(predicted_classes));
            accuracy_prediction = predicted_classes == testing_groups;
            temp_sub_index = 0;
			if testing_indexgroup1 ~= 0
            	for i = 1:ngroup1_substested
                	temp_sub_index = temp_sub_index + 1;
                	group1class(i) = accuracy_prediction(temp_sub_index);
                    group1predict(i) = predicted_classes(temp_sub_index);
                    group1scores(i) = predicted_scores(temp_sub_index);
            	end
			else
				group1class = NaN;
			end
			if testing_indexgroup2 ~= 0
            	for i = 1:ngroup2_substested
                	temp_sub_index = temp_sub_index + 1;
                	group2class(i) = accuracy_prediction(temp_sub_index);
                    group2predict(i) = predicted_classes(temp_sub_index);
                    group2scores(i) = predicted_scores(temp_sub_index);
            	end
			else
				group2class = NaN;
			end           
            accuracy = zeros(ngroups+1,1);
%            accuracy(1,1) = size(find(accuracy_prediction == ngroups_index(1)),1)/size(testing_groups,1);
            for n = 1:ngroups
                accuracy(n+1,1) = size(find(accuracy_prediction(testing_groups == ngroups_index(n)) == 1),1)/size(find(testing_groups == ngroups_index(n)),1);
                accuracy(1,1) = accuracy(1,1) + size(find(accuracy_prediction(testing_groups == ngroups_index(n)) == 1),1);
            end
            accuracy(1,1) = accuracy(1,1)/size(testing_groups,1);
        end        
    case('validationPlusOOB_weighted')
        ngroups_index = union(unique(testing_groups),unique(learning_groups));
        ngroups = max(size(ngroups_index));
        [predicted_classes,predicted_scores] = predict(treebag,testing_data,'TreeWeights',treeweights,'Surrogate',surrogate);
        predicted_classes = str2num(cell2mat(predicted_classes));
        if strcmp(varargin{1},'regression')
            accuracy = zeros(3,1);
            predicted_classes_new = zeros(max(max(size(predicted_classes))),1);
            for blah = 1:max(max(size(predicted_classes)))
                predicted_classes_new(blah) = str2num(predicted_classes{blah});
            end
            temp_sub_index = 0;
			if testing_indexgroup1 ~= 0
            	for i = 1:ngroup1_substested
                	temp_sub_index = temp_sub_index + 1;
                	group1class(i) = abs(predicted_classes_new(temp_sub_index) - testing_groups(temp_sub_index));
                    group1predict(i) = predicted_classes_new(temp_sub_index);
                    group1scores(i) = predicted_scores(temp_sub_index);
            	end
			else
				group1class = NaN;
			end
			if testing_indexgroup2 ~= 0
            	for i = 1:ngroup2_substested
                	temp_sub_index = temp_sub_index + 1;
                	group2class(i) = abs(predicted_classes_new(temp_sub_index) - testing_groups(temp_sub_index));
                    group2predict(i) = predicted_classes_new(temp_sub_index);
                    group2scores(i) = predicted_scores(temp_sub_index);
            	end            
			else
				group2class = NaN;
			end  
            accuracy_prediction = abs(predicted_classes_new - testing_groups);
            accuracy(1,1) = mean(accuracy_prediction);
            accuracy(2,1) = corr(predicted_classes_new,testing_groups);
            N = max(max(size(testing_groups)));
            mean_all = (accuracy(1,1)+mean(testing_groups))/2;
            nx1=0;
            nx2=0;
            nxpooled=0;
            for i = 1:N
                nx1=nx1+(testing_groups(i) - mean_all)^2;
                nx2=nx2+(predicted_classes_new(i) - mean_all)^2;
                nxpooled = nxpooled + ((predicted_classes_new(i) - mean_all)*(testing_groups(i) - mean_all));
            end
            s_squared = (nx1+nx2)/((2*N)-1);
            accuracy(3,1) = nxpooled/(N*s_squared);
        else
            accuracy_prediction = predicted_classes == testing_groups;
			temp_sub_index = 0;
			if testing_indexgroup1 ~= 0
            	for i = 1:ngroup1_substested
                	temp_sub_index = temp_sub_index + 1;
                	group1class(i) = accuracy_prediction(temp_sub_index);
                    group1predict(i) = predicted_classes(temp_sub_index);
                    group1scores(i) = predicted_scores(temp_sub_index);
            	end
			else
				group1class = NaN;
			end
			if testing_indexgroup2 ~= 0
            	for i = 1:ngroup2_substested
                	temp_sub_index = temp_sub_index + 1;
                	group2class(i) = accuracy_prediction(temp_sub_index);
                    group2predict(i) = predicted_classes(temp_sub_index);
                    group2scores(i) = predicted_scores(temp_sub_index);
            	end
			else
				group2class = NaN;
			end             
            accuracy = zeros(ngroups+1,1);
%            accuracy(1,1) = size(find(accuracy_prediction == ngroups_index(1)),1)/size(testing_groups,1);
            for n = 1:ngroups
                accuracy(n+1,1) = size(find(accuracy_prediction(testing_groups == ngroups_index(n)) == 1),1)/size(find(testing_groups == ngroups_index(n)),1);
                accuracy(1,1) = accuracy(1,1) + size(find(accuracy_prediction(testing_groups == ngroups_index(n)) == 1),1);
            end
            accuracy(1,1) = accuracy(1,1)/size(testing_groups,1);
        end        
    case('EstimatePredictorsToSample')
        initial_predictors = numpredictors; %%change if you want to examine smaller numbers, can be used as an input to the function itself
        predictor_step = 20; %%change if you want to examine finer numbers -- lower numbers will slow the function
        limit_nodice = 5;
        if strcmp(class_method,'regression')
            treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','on','NVarToSample',initial_predictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate,'Method',class_method);        
        else
            treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','on','NVarToSample',initial_predictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate,'Prior',prior,'Method',class_method);
        end
        nvars = size(learning_data,2);
        outofbag_error_first = oobError(treebag);
        outofbag_error_first = outofbag_error_first(end);
        optimal_predictors = numpredictors;
        optimal_prediction = outofbag_error_first;
        final_predictors = initial_predictors + predictor_step;
        count = 0;
        while final_predictors <= nvars && count < limit_nodice
        if strcmp(class_method,'regression')
            treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','on','NVarToSample',initial_predictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate,'Method',class_method);        
        else
            treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','on','NVarToSample',initial_predictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate,'Prior',prior,'Method',class_method);
        end
            outofbag_error_second = oobError(treebag);
            outofbag_error_second = outofbag_error_second(end);
            if outofbag_error_second < optimal_prediction
                sprintf('%s',strcat('Accuracy improved by: %',num2str(100*(optimal_prediction - outofbag_error_second))))
                sprintf('%s',strcat('Accuracy is now : %',num2str(100*(1 - outofbag_error_second))))
                optimal_prediction = outofbag_error_second;
                optimal_predictors = final_predictors;
                sprintf('%s',strcat('Number of predictors is: #',num2str(optimal_predictors)))
                count = 0;
            end
            final_predictors = final_predictors + predictor_step;
            count = count + 1;
        end
        accuracy = optimal_predictors;
        sprintf('%s',strcat('Optimization found! Number of predictors: #',num2str(accuracy))) 
end
end

