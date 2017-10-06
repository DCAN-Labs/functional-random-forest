load('ASD_n47_10_4_16.mat')
load('Controls_n58_10_4_16.mat')
rng('shuffle')
data = cell2mat(ASD);
data(end+1:end+58,:) = cell2mat(Controls);
nreps = 1000;
ntrees = 200;
train = 0.6;
nfeatures = 6;
nterminals = 10;
accuracy = zeros(3,nreps);
permute_accuracy = zeros(3,nreps);
proxmat = cell(nreps,1);
forests = cell(nreps,1);
ntrain_asd = round(47*train);
ntrain_controls = round(58*train);
outcomes(1:47,1) = 0;
outcomes(48:105,1) = 1;
outcomes(:,2) = 1:105;
for i = 1:nreps
    data_train = ismember(1:47,randperm(47,ntrain_asd));
    data_train(end+1:end+58) = ismember(1:58,randperm(58,ntrain_controls));
    training_data = data(data_train,:);
    test_data = data(data_train==0,:);
    train_outcomes(1:ntrain_asd,1) = 0;
    train_outcomes(ntrain_asd+1:ntrain_asd+ntrain_controls,1) = 1;
    train_outcomes(:,2) = 1:size(train_outcomes,1);
    permuted_train_outcomes = train_outcomes;
    permuted_train_outcomes(:,1) = permuted_train_outcomes(randperm(size(train_outcomes,1)),1);
    test_outcomes(1:47-ntrain_asd,1) = 0;
    test_outcomes(47-ntrain_asd+1:(47-ntrain_asd)+(58-ntrain_controls),1) = 1;
    test_outcomes(:,2) = 1:size(test_outcomes,1);
    permuted_test_outcomes = test_outcomes;
    permuted_test_outcomes(:,1) = permuted_test_outcomes(randperm(size(test_outcomes,1)),1);
    forests{i} = FForest;
    forests{i} = forests{i}.GrowForest(training_data,train_outcomes,200,round(2*size(training_data,1)/3),6,10);
    temp_forest = FForest;
    temp_forest = temp_forest.GrowForest(training_data,permuted_train_outcomes,200,round(2*size(training_data,1)/3),6,10);
    predicted_test_outcomes = forests{i}.Predict(test_data);
    predicted_permute_outcomes = temp_forest.Predict(test_data);
    [~,proxmat{i}] = forests{i}.Predict(data);
    permute_performance_vector = abs(permuted_test_outcomes(:,1) - predicted_permute_outcomes);
    performance_vector = abs(test_outcomes(:,1) - predicted_test_outcomes);
    accuracy(1,i) = 1 - (sum(performance_vector)/length(performance_vector));
    accuracy(2,i) = 1 - (sum(performance_vector(test_outcomes(:,1)==0))/length(performance_vector(test_outcomes(:,1)==0)));
    accuracy(3,i) = 1 - (sum(performance_vector(test_outcomes(:,1)==1))/length(performance_vector(test_outcomes(:,1)==1)));
    permute_accuracy(1,i) = 1 - (sum(permute_performance_vector)/length(permute_performance_vector));
    permute_accuracy(2,i) = 1 - (sum(permute_performance_vector(permuted_test_outcomes(:,1)==0))/length(permute_performance_vector(permuted_test_outcomes(:,1)==0)));
    permute_accuracy(3,i) = 1 - (sum(permute_performance_vector(permuted_test_outcomes(:,1)==1))/length(permute_performance_vector(permuted_test_outcomes(:,1)==1)));    
    sprintf(strcat('run #',num2str(i),' complete!'))
end
save('../summary_output_CS569.mat','accuracy','permute_accuracy','proxmat','forests');
%split data by ASD and control communities
load('summary_output_CS569.mat','proxmat');
for i = 1:nreps
    proxmat_ASD{i} = proxmat{i}(1:47,1:47);
    proxmat_control{i} = proxmat{i}(48:105,48:105);
end
[community_ASD, sorting_order_ASD,commproxmat_ASD] = RunAndVisualizeCommunityDetection(proxmat_ASD,'../CS569_FForest_ASD','/group_shares/PSYCH/code/internal/release/utilities/simple_infomap.py',100,'LowDensity',0.1,'StepDensity',0.01,'HighDensity',0.2);
[community_control, sorting_order_control,commproxmat_control] = RunAndVisualizeCommunityDetection(proxmat_control,'../CS569_FForest_control','/group_shares/PSYCH/code/internal/release/utilities/simple_infomap.py',100,'LowDensity',0.1,'StepDensity',0.01,'HighDensity',0.2);