#! /bin/bash
source $1
#set defaults from source file
if $groupby; then groupby_flag='GroupBy'; else groupby_flag='NONE'; fi
#If missing parameters, set defaults for other vars
input_data_variable=${input_data_variabl:-'input_data'}
group_data_variable=${group_data_variable:-'group_data'}
infomapfile=${infomapfile:-'/group_shares/fnl/bulk/code/external/utilities/infomap/Infomap'}
repopath=${repopath:-'/group_shares/fnl/bulk/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis'}
matlab_command=${matlab_command:-'matlab'}
output_directory=${output_directory:-'LONG_ADHD_OHSU_dataset'}
categorical_vector=${categorical_vector:-0}
forest_type=${forest_type:-'classification'}
learning_type=${learning_type:-'supervised'}
outcome_regression_column=${outcome_regression_column:-1}
num_sim_cases=${num_sim_cases:-100}
num_sims=1000=${num_sims:-1000}
performance_thresholds=${performance_thresholds:-0.6}
num_cores=${num_cores:-1}
#run power analysis command
${matlab_command} -nodisplay -nosplash -r "addpath('"${repopath}"') ; RunRFSDPowerAnalysis('InputData',struct('path','"${input_data}"','variable','"${input_data_variable}"'),'"$groupby_flag"',struct('path','"${group_data}"','variable','"${group_data_variable}"'),'Categorical','"$categorical_vector"','NumSumCases',"$num_sim_cases",'DataRange',"$data_range",'OutputDirectory','"$output_directory"','PerformanceThresholds',"$performance_thresholds",'ForestType','"$forest_type"','LearningType','"$learning_type"','NumCores',"$num_cores",'NumSimulations',"$num_sims",'OutcomeColumnForRegression',"$outcome_regression_column",'InfomapFile','"$infomapfile"','CommandFile','"$command_file"'); exit"
