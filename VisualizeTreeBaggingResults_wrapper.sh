#! /bin/bash
#VisualizeTreeBaggingResults_wrapper.sh requires a ParamFile as an input (e.g. VisualizeTreeBaggingResults_wrapper.sh VisualizeTreeBagResults_example.bash). See the VisualizeTreeBagResults_example.bash for more information on available parameters.
source $1
use_group2_data=${use_group2_data:-'false'}
regression=${regression:-'false'}
#parameters set from the VisualizeTreeBagResultsParamFile
if $use_group2_data; then group2_data="struct('path','"${group2path}"','variable','"${group2var}"')"; else group2_data=0; fi
if $regression; then regression='regression'; else regression='classification'; fi
#If missing parameters, set defaults
filename=${filename:-'thenamelessone'}
regression=${regression:-'classification'}
infomap_command_file=${infomap_command_file:-'/group_shares/fnl/bulk/code/internal/utilities/simple_infomap/simple_infomap.py'}
lowdensity=${lowdensity:-0.2}
stepdensity=${stepdensity:-0.05}
highdensity=${highdensity:-1}
#Construct the model, which will save outputs to a filename.mat file
matlab -nodisplay -nosplash -singleCompThread -r "addpath('/group_shares/fnl/bulk/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis') ; VisualizeTreeBaggingResults('"$results_matfile"','"$filename"','"$regression"',struct('path','"${group1path}"','variable','"${group1var}"'),"$group2_data",'"$infomap_command_file"','LowDensity',"$lowdensity",'StepDensity',"$stepdensity",'HighDensity',"$highdensity"); exit"
