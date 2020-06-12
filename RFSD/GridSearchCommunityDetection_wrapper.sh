#!/bin/bash

set -euo pipefail

# RunAndVisualizeCommunityDetection_wrapper.sh requires a ParamFile as an input (e.g. RunAndVisualizeCommunityDetection_wrapper.sh RunAndVisualizeCommunityDetection_example.bash). See the RunAndVisualizeCommunityDetection_example.bash for more information on available parameters.
source $1

#If missing parameters, set defaults
filename=${filename:-'thenamelessone'}
infomap_command_file=${infomap_command_file:-'/group_shares/fnl/bulk/code/internal/utilities/simple_infomap/simple_infomap.py'}
lowdensitymin=${lowdensitymin:-0.01}
lowdensitystep=${lowdensitystep:-0.01}
lowdensitymax=${lowdensitymax:-0.2}
stepdensitymin=${stepdensitymin:-0.05}
stepdensitystep=${stepdensitystep:-0.05}
stepdensitymax=${stepdensitymax:-1}
highdensitymin=${highdensitymin:-0.2}
highdensitystep=${highdensitystep:-0.1}
highdensitymax=${highdensitymax:-1}
infomapfile=${infomapfile:-'/group_shares/fnl/bulk/code/external/utilities/infomap/Infomap'}
repopath=${repopath:-'/group_shares/fnl/bulk/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis'}
matlab_command=${matlab_command:-'matlab'}
infomap_nreps=${infomap_nreps:-10}
#Construct the model, which will save outputs to a filename.mat file
${matlab_command} -nodisplay -nosplash -r "addpath('"${repopath}"') ; GridSearchCommunityDetection(struct('path','"${corrmatpath}"','variable','"${corrmatvar}"'),'"$filename"','"$infomap_command_file"',"$infomap_nreps",'LowDensityMin',"$lowdensitymin",'LowDensityStep',"$lowdensitystep",'LowDensityMax',"$lowdensitymax",'StepDensityMin',"$stepdensitymin",'StepDensityStep',"$stepdensitystep",'StepDensityMax',"$stepdensitymax",'HighDensityMin',"$highdensitymin",'HighDensityStep',"$highdensitystep",'HighDensityMax',"$highdensitymax",'InfomapFile','"$infomapfile"'); exit"
