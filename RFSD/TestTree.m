function [accuracy,pruned_tree,crossval_E,crossval_E_SE,crossval_terminals,optimal_prune] = TestTree(learning_groups, learning_data, testing_groups, testing_data,nkfolds)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
ngroups = size(unique(testing_groups),1);
initial_tree = fitctree(learning_data,learning_groups);
[crossval_E,crossval_E_SE,crossval_terminals,optimal_prune] = cvloss(initial_tree,'Subtrees','all','KFold',nkfolds);
pruned_tree = prune(initial_tree,'level',optimal_prune);
predicted_classes = predict(pruned_tree,testing_data);
accuracy_prediction = predicted_classes == testing_groups;
accuracy = zeros(ngroups+1,1);
accuracy(1,1) = size(find(accuracy_prediction == 1),1)/size(testing_groups,1);
for n = 1:ngroups
    accuracy(n+1,1) = size(find(accuracy_prediction(testing_groups == n-1) == 1),1)/size(find(testing_groups == n-1),1);
end
end

