#! /bin/bash
source $1
#set defaults from source file
if $groupby; then groupby_flag='GroupBy'; else groupby_flag='NONE'; fi
if $zscore_flag; then zscore='ZscoreOutcomeVariable'; else zscore='NONE'; fi
#If missing parameters, set defaults for other vars
input_data_variable=${input_data_variable:-'input_data'}
group_data_variable=${group_data_variable:-'group_data'}
infomapfile=${infomapfile:-'/group_shares/fnl/bulk/code/external/utilities/infomap/Infomap'}
repopath=${repopath:-'/group_shares/fnl/bulk/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis'}
command_file=${command_file:-'/group_shares/fnl/bulk/code/internal/utilities/simple_infomap/simple_infomap.py'}
matlab_command=${matlab_command:-'matlab'}
output_directory=${output_directory:-'LONG_ADHD_OHSU_dataset'}
categorical_vector=${categorical_vector:-0}
forest_type=${forest_type:-'Classification'}
learning_type=${learning_type:-'supervised'}
outcome_regression_column=${outcome_regression_column:-1}
num_sim_cases=${num_sim_cases:-100}
num_sims=${num_sims:-1000}
performance_thresholds=${performance_thresholds:-0.6}
num_cores=${num_cores:-1}
data_range=${data_range:-0}
#run power analysis command
${matlab_command} -nodisplay -nosplash -r "addpath('"${repopath}"') ; RunRFSDPowerAnalysis('InputData',struct('path','"${input_data}"','variable','"${input_data_variable}"'),'"$groupby_flag"',struct('path','"${group_data}"','variable','"${group_data_variable}"'),'Categorical','"$categorical_vector"','NumSimCases',"$num_sim_cases",'DataRange',"$data_range",'OutputDirectory','"$output_directory"','PerformanceThresholds',"$performance_thresholds",'ForestType','"$forest_type"','LearningType','"$learning_type"','NumCores',"$num_cores",'NumSimulations',"$num_sims",'OutcomeColumnForRegression',"$outcome_regression_column",'InfomapFile','"$infomapfile"','CommandFile','"$command_file"','"$zscore"'); exit"
