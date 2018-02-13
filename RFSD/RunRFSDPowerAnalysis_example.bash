#! /bin/bash
##input and output parameters
input_data=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Long_ADHD_OHSU/raw_data.mat #path and filename where the input data are located
input_data_variable=input_data #the name of the input variable stored in the .mat file
groupby=true #if set to true, a group_data column will be loaded as well
	group_data=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Long_ADHD_OHSU/raw_data.mat #path and filename to where the group_column is stored can be same or different .mat file
	group_data_variable=group_data #the name of the group variable stored in the .mat file
output_directory=LONG_ADHD_OHSU_dataset #the name of the output prefix
categorical_vector=[2 3 4] #a numeric vector encapsulated by square brackets, where each number denotes a column that represents a categorical variable, set to 0 if no such variable exists

##dependency parameters
repopath=/group_shares/fnl/bulk/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis #the full path to the repository containing the RFAnalysis code.
matlab_command=matlab #the name of the matlab command line executable, can include arguments additional options, etc. SingleCompThread is enabled by default.
infomapfile=/group_shares/fnl/bulk/code/external/utilities/infomap/Infomap #the full path and filename for the Infomap executable, must be installed from http://mapequation.org
commandfile=/group_shares/fnl/bulk/code/internal/utilities/simple_infomap/simple_infomap.py

##random forest parameters
forest_type='classification' #sets whether a regression or classification RF is generated
learning_type='supervised' #sets whether one is testing a supervised or unsupervised algorithm.
outcome_regression_column=0 #if regression is selected, the number represents the column in the data matrix containing the outcome measure

##power analysis parameters
num_sim_cases=100 #the sample size to simulate
num_sims=1000 #the number of simulations to run
performance_thresholds=[0.4 0.5 0.6 0.7 0.8] #the thresholds for performance to use to calculate statistical power

##parallel execution parameters
num_cores=1 #the number of cores to use for parallel execution
