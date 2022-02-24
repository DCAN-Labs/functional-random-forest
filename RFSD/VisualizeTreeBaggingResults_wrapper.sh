#! /bin/bash
#VisualizeTreeBaggingResults_wrapper.sh requires a ParamFile as an input (e.g. VisualizeTreeBaggingResults_wrapper.sh VisualizeTreeBagResults_example.bash). See the VisualizeTreeBagResults_example.bash for more information on available parameters.
set -e

source $1
use_group2_data=${use_group2_data:-'false'}
regression=${regression:-'false'}
use_gridsearch=${use_gridsearch:-'false'}
#parameters set from the VisualizeTreeBagResultsParamFile
if $use_group2_data; then group2_data="struct('path','"${group2path}"','variable','"${group2var}"')"; else group2_data=0; fi
if $regression; then regression='regression'; else regression='classification'; fi
if $use_gridsearch; then gridsearch_flag='GridSearchDir'; else gridsearch_flag='NULL'; fi
#If missing parameters, set defaults
filename=${filename:-'thenamelessone'}
regression=${regression:-'classification'}
infomap_command_file=${infomap_command_file:-'/group_shares/fnl/bulk/code/internal/utilities/simple_infomap/simple_infomap.py'}
repopath=${repopath:-'/group_shares/fnl/bulk/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis'}
matlab_command=${matlab_command:-'matlab'}
showmpath=${showmpath:-'/home/faird/shared/code/internal/utilities/plotting-tools/showM/'}
gridsearch=${gridsearch:-'NULL'}
grammpath=${grammpath:-'/home/faird/shared/code/external/utilities/gramm'}
lowdensity=${lowdensity:-0.2}
stepdensity=${stepdensity:-0.05}
highdensity=${highdensity:-1}
junk_threshold=${junk_threshold:-30}
bct_path=${bct_path:-'/home/faird/shared/code/external/utilities/BCT/BCT/2019_03_03_BCT'}
connectedness_thresh=${connectedness_thresh:-0.7}

module load matlab
#Construct the model, which will save outputs to a filename.mat file
${matlab_command} -nodisplay -nosplash -singleCompThread -r "addpath(genpath('"${repopath}"')) ; VisualizeTreeBaggingResults('"$results_matfile"','"$filename"','"$regression"','"$infomap_command_file"','LowDensity',"$lowdensity",'StepDensity',"$stepdensity",'HighDensity',"$highdensity",'InfomapFile','"$infomapfile"','ShowMPath','"$showmpath"','GrammPath','"$grammpath"','"$gridsearch_flag"','"$gridsearch"','JunkThreshold',"$junk_threshold",'BCTPath','"$bct_path"','ConnectednessThreshold',"$connectedness_thresh"); exit"
