function [accuracy,treebag,outofbag_error] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees,type,treebag,treeweights)
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
switch(type)
    case('estimate_trees')
        initial_trees = 50; %%change if you want to examine smaller numbers, generally at least 50 trees will be needed for most weak classifiers
        tree_step = 10; %%change if you want to examine finer numbers -- lower numbers will slow the function
        treebag = TreeBagger(initial_trees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','on');
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
    case('weight_trees')
        treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','off');
        accuracy = zeros(ntrees,1);
        for i = 1:ntrees
            prediction_classes = str2num(cell2mat(predict(treebag,treebag.X,'Trees',i)));
            accurate_classes = learning_groups == prediction_classes;
            accuracy(i,1) = var(fitdist(double(accurate_classes),'Binomial'));
        end
    case('validation')
        ngroups = size(unique(testing_groups),1);
        treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','off');
        outofbag_error = NaN;
        predicted_classes = str2num(cell2mat(predict(treebag,testing_data)));
        accuracy_prediction = predicted_classes == testing_groups;
        accuracy = zeros(ngroups+1,1);
        accuracy(1,1) = size(find(accuracy_prediction == 1),1)/size(testing_groups,1);
        for n = 1:ngroups
            accuracy(n+1,1) = size(find(accuracy_prediction(testing_groups == n-1) == 1),1)/size(find(testing_groups == n-1),1);
        end
    case('validation_weighted')
        ngroups = size(unique(testing_groups),1);
        outofbag_error = NaN;
        predicted_classes = str2num(cell2mat(predict(treebag,testing_data,'TreeWeights',treeweights)));
        accuracy_prediction = predicted_classes == testing_groups;
        accuracy = zeros(ngroups+1,1);
        accuracy(1,1) = size(find(accuracy_prediction == 1),1)/size(testing_groups,1);
        for n = 1:ngroups
            accuracy(n+1,1) = size(find(accuracy_prediction(testing_groups == n-1) == 1),1)/size(find(testing_groups == n-1),1);
        end
    case('validationPlusOOB')
        ngroups = size(unique(testing_groups),1);
        treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','on');
        outofbag_error = oobError(treebag);
        predicted_classes = str2num(cell2mat(predict(treebag,testing_data)));
        accuracy_prediction = predicted_classes == testing_groups;
        accuracy = zeros(ngroups+1,1);
        accuracy(1,1) = size(find(accuracy_prediction == 1),1)/size(testing_groups,1);
        for n = 1:ngroups
            accuracy(n+1,1) = size(find(accuracy_prediction(testing_groups == n-1) == 1),1)/size(find(testing_groups == n-1),1);
        end
    case('validationPlusOOB_weighted')
        ngroups = size(unique(testing_groups),1);
        predicted_classes = str2num(cell2mat(predict(treebag,testing_data,'TreeWeights',treeweights)));
        accuracy_prediction = predicted_classes == testing_groups;
        accuracy = zeros(ngroups+1,1);
        accuracy(1,1) = size(find(accuracy_prediction == 1),1)/size(testing_groups,1);
        for n = 1:ngroups
            accuracy(n+1,1) = size(find(accuracy_prediction(testing_groups == n-1) == 1),1)/size(find(testing_groups == n-1),1);
        end
end
end

