function [ accuracy, permuted_accuracy] = PerformRFSDSimulations(varargin)
%PerformRFSDSimulations will run a RFSD simulation and output performance
%metrics 
%   Detailed explanation goes here
categorical_vector = 0;
ncases = 1;
group_column = 0;
data_range = 0;
forest_type = 'Classification';
learning_type = 'supervised';
outcol = 1;
infomapfile='/group_shares/fnl/bulk/code/external/infomap/Infomap';
commandfile = '/group_shares/fnl/bulk/code/internal/utilities/simple_infomap/simple_infomap.py';
for i = 1:size(varargin,2)
    if ischar(varargin{i})
        switch(varargin{i})
            case('InputData')
                input_data = varargin{i+1};
            case('GroupBy')
                group_column = varargin{i+1};
                if  (max(size(group_column))) < 2 && (group_column == 0)
                    ngroups = 0;
                else
                    ngroups = length(unique(group_column));
                end
            case('Categorical')
                categorical_vector = varargin{i+1};
            case('NumSimCases')
                ncases = varargin{i+1};
            case('DataRange')
                data_range = varargin{i+1};
            case('ForestType')
                forest_type = varargin{i+1};
            case('LearningType')
                learning_type = varargin{i+1};     
            case('OutcomeColumnForRegression')
                outcol = varargin{i+1};
            case('InfomapFile')
                infomapfile = varargin{i+1};
            case('CommandFile')
                commandfile = varargin{i+1};
        end
    end
end
%declare outputs
if strcmp(forest_type,'Regression')
    accuracy = zeros(2,1);
else
    accuracy = zeros(ngroups+1,1);
end
if strcmp(learning_type,'unsupervised')
    accuracy = 0;
end
permuted_accuracy = accuracy;
output_temp_dir = 'simulated';
%generate simulated data and output TRUE groups
[simulated_data,~,groups] = SimulateGroupData('InputData',input_data,'GroupBy',group_column,'Categorical',categorical_vector,'NumSimCases',ncases,'DataRange',data_range,'NoSave');
%run simulated data through RF model: supervised differs from
%unsupervised
switch(learning_type)
%for supervised cases, we will use the TRUE group to verify accuracy from the RF itself
%if regression is used, no TRUE group exists, instead the
%OutcomeColumnForRegression will be used instead
    case('supervised')
        if strcmp(forest_type,'Regression')
            true_outcomes = simulated_data(:,outcol);
            mean_outcome = mean(true_outcomes);
            sd_outcome = std(true_outcomes);
        else
            true_outcomes = groups;
            temp_simulated_data = zeros(size(simulated_data,1),1+size(simulated_data,2));
            temp_simulated_data(:,1) = true_outcomes;
            temp_simulated_data(:,2:end) = simulated_data;
            simulated_data = temp_simulated_data;
        end
        [run_accuracy,run_permute_accuracy] = ConstructModelTreeBag(simulated_data,0,0.7,3,1000,0,output_temp_dir,1000000,'NoSave','TreebagsOff','CrossValidate',10,'Uniform',forest_type,'useoutcomevariable',outcol,outcol);
        switch(forest_type)
            case('Classification')
                accuracy(:,1) = mean(mean(run_accuracy,2),3);
                permuted_accuracy(:,1) = mean(mean(run_permute_accuracy,2),3);
            case('Regression')
                accuracy(:,1) = mean(mean(run_accuracy(1:2,:,:),2),3);
                permuted_accuracy(:,1) = mean(mean(run_permute_accuracy(1:2,:,:),2),3);
                accuracy(1,1) = (accuracy(1,1) - mean_outcome)/sd_outcome; %convert to z-score for power analysis
                permuted_accuracy(1,1) = (permuted_accuracy(1,1) - mean_outcome)/sd_outcome;
        end
    case('unsupervised')
        while size(dir(strcat(output_temp_dir,'_output')),1) > 0
            output_temp_dir = strcat(output_temp_dir,num2str(randi(10,1)-1));
        end
        simulated_permuted_data = SimulateGroupData('InputData',input_data,'GroupBy',group_column(randperm(length(group_column))),'Categorical',categorical_vector,'NumSimCases',ncases,'DataRange',data_range,'NoSave');
        ConstructModelTreeBag(simulated_data,0,0.7,3,1000,0,output_temp_dir,10000000,'TreebagsOff','CrossValidate',10,'unsupervised','Classification','InfomapFile',infomapfile,'CommandFile',commandfile);
        observed_outcomes = struct2array(load(strcat(output_temp_dir,'_output/community_assignments.mat'),'community_matrix'));
        observed_mat = zeros(length(observed_outcomes));
        ConstructModelTreeBag(simulated_permuted_data,0,0.7,3,1000,0,output_temp_dir,10000000,'TreebagsOff','CrossValidate',10,'unsupervised','Classification','InfomapFile',infomapfile,'CommandFile',commandfile);
        permuted_outcomes = struct2array(load(strcat(output_temp_dir,'_output/community_assignments.mat'),'community_matrix'));
        permuted_mat = zeros(length(permuted_outcomes));
        permuted_ncomms = unique(permuted_outcomes);
        true_mat = zeros(length(group_columns));
        true_ncomms = unique(group_column);
        observed_ncomms = unique(observed_outcomes);
        for curr_comm = 1:length(true_ncomms)
            cases_in_comm = find(group_column == true_ncomms(curr_comm));
            true_mat(cases_in_comm,cases_in_comm) = true_mat(cases_in_comm,cases_in_comm) + 1;
        end
        for curr_comm = 1:length(observed_ncomms)
            cases_in_comm = find(observed_outcomes == observed_ncomms(curr_comm));
            observed_mat(cases_in_comm,cases_in_comm) = observed_mat(cases_in_comm,cases_in_comm) + 2;
        end
        for curr_comm = 1:length(permuted_ncomms)
            cases_in_comm = find(permuted_outcomes == permuted_ncomms(curr_comm));
            permuted_mat(cases_in_comm,cases_in_comm) = permuted_mat(cases_in_comm,cases_in_comm) + 2;
        end
        comp_mat = observed_mat + true_mat;
        permuted_comp_mat = permuted_mat + true_mat;
        nodepairs = length(comp_mat)*(length(comp_mat) -1)/2;
        A = (length(find(comp_mat == 3)) - length(comp_mat))/2; %same true - same observed
        B = (length(find(comp_mat == 1)) - length(comp_mat))/2; %same true - different observed
        C = (length(find(comp_mat == 2)) - length(comp_mat))/2; %different true - same observed
        D = (length(find(comp_mat == 0)) - length(comp_mat))/2; %different true - different observed
        perm_A = (length(find(permuted_comp_mat == 3)) - length(permuted_comp_mat))/2; %same true - same observed
        perm_B = (length(find(permuted_comp_mat == 1)) - length(permuted_comp_mat))/2; %same true - different observed
        perm_C = (length(find(permuted_comp_mat == 2)) - length(permuted_comp_mat))/2; %different true - same observed
        perm_D = (length(find(permuted_comp_mat == 0)) - length(permuted_comp_mat))/2; %different true - different observed
        accuracy = ((nodepairs*(A+D))-((A+B)*(A+C) + (C+D)*(B+D)))/(nodepairs - ((A+B)*(A+C) + (C+D)*(B+D)));
        permuted_accuracy = ((nodepairs*(perm_A+perm_D))-((perm_A+perm_B)*(perm_A+perm_C) + (perm_C+perm_D)*(perm_B+perm_D)))/(nodepairs - ((perm_A+perm_B)*(perm_A+perm_C) + (perm_C+perm_D)*(perm_B+perm_D)));   
        system(['rm -rf ' output_temp_dir '_output']);
        system(['rm -rf ' output_temp_dir '.mat']);
end  
end

