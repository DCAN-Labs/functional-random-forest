#!/bin/bash


# ConstructModelTreeBag_wrapper.sh requires a ParamFile as an input
# (e.g. ConstructModelTreeBag_wrapper.sh TreeBagParamFile_example.bash).
# See the TreeBagParamFile_example.bash for more information on available
# parameters.

set -e # error out on failure

source $1

#declare missing parameters that have logic flow as false -- correction 12/14/16
outcome_variable_exist=${outcome_variable_exist:-'false'}
matchgroups=${matchgroups:-'false'}
OOB_error=${OOB_error:-'false'}
holdout=${holdout:-'false'}
estimate_trees=${estimate_trees:-'false'}
weight_trees=${weight_trees:-'false'}
trim_features=${trim_features:-'false'}
estimate_predictors=${estimate_predictors:-'false'}
estimate_treepred=${estimate_treepred:-'false'}
regression=${regression:-'false'}
surrogate=${surrogate:-'false'}
group2test=${group2test:-'false'}
fisher_z_transform=${fisher_z_transform:-'false'}
cross_validate=${cross_validate:-'true'}
dim_reduce=${dim_reduce:-'false'}
graph_reduce=${graph_reduce:-'false'}
connmat_reduce=${connmat_reduce:-'false'}
showmpath=${showmpath:-'/home/faird/shared/code/internal/utilities/plotting-tools/showM/'}
grammpath=${grammpath:-'/home/faird/shared/code/external/utilities/gramm'}
bct_path=${bct_path:-'/home/faird/shared/code/external/utilities/BCT/BCT/2019_03_03_BCT'}
connectedness_thresh=${connectedness_thresh:-0.7}
gridsearch=${gridsearch:-'NULL'}
use_gridsearch=${use_gridsearch:-'false'}

#parameters set from the TreeBagParamFile
if $use_gridsearch; then gridsearch_flag='GridSearchDir'; else gridsearch_flag='NULL'; fi
if $use_group2_data; then group2_data="struct('path','"${group2path}"','variable','"${group2var}"')"; else group2_data=0; fi
if $estimate_trees; then estimate_trees='EstimateTrees'; else estimate_trees='NONE'; fi
if $weight_trees; then weight_trees='WeightForest'; else weight_trees='NONE'; fi
if $trim_features; then trim_features='TrimFeatures'; else trim_features='NONE'; fi
if $fisher_z_transform; then fisher_z_transform='FisherZ'; else fisher_z_transform='NONE'; fi
if $disable_treebag; then disable_treebag='TreebagsOff'; else disable_treebag='NONE'; fi
if $holdout; then holdout='Holdout'; else holdout='NONE'; fi
if $npredictors; then npredictors='npredictors'; else npredictors='NONE'; fi
if $estimate_predictors; then estimate_predictors='EstimatePredictors'; else estimate_predictors='NONE'; fi
if $estimate_treepred; then estimate_treepred='EstimateTreePredictors'; else estimate_treepred='NONE'; fi
if $OOB_error; then OOB_error='OOBErrorOn'; else OOB_error='NONE'; fi
if $regression; then regression='Regression'; else regression='NONE'; fi
if $outcome_variable; then outcome_variable_exist='useoutcomevariable'; if $outcome_is_struct; then group1outcome="struct('path','"${group1outcome_path}"','variable','"${group1outcome_var}"')"; group2outcome="struct('path','"${group2outcome_path}"','variable','"${group2outcome_var}"')"; else group1outcome=$group1outcome_num; group2outcome=$group2outcome_num; fi; else group1outcome=0; group2outcome=0; fi
if $surrogate; then surrogate='surrogate'; else surrogate='NONE'; fi
if $group2_validate_only; then group2test='group2istestdata'; else group2test='NONE'; fi
if $uniform_priors; then priors='Uniform'; else priors='Empirical'; fi
if $use_unsupervised; then unsupervised='unsupervised'; else unsupervised='NONE'; fi
if $matchgroups; then matchgroups='MatchGroups'; else matchgroups='NONE'; fi
if $cross_validate; then cv='CrossValidate'; else cv='NONE'; fi
if $dim_reduce; then reducedim='DimReduce'; else reducedim='NONE'; fi
if $graph_reduce; then reducegraph='GraphReduce'; else reducegraph='NONE'; fi
if $connmat_reduce; then reduceconnmat='ConnMatReduce'; else reduceconnmat='NONE'; fi

#If missing other parameters, set defaults
datasplit=${datasplit:-0.9}
ntrees=${ntrees:-10000}
nreps=${nreps:-3}
nfolds=${nfolds:-10}
nperms=${nperms:-0}
filename=${filename:-'thenamelessone'}
nfeatures=${nfeatures:-0}
disable_treebag=${disable_treebag:-'TreebagsOff'}
holdout_data=${holdout_data:-'NONE'}
group_holdout=${group_holdout:-0}
proxsublimit_num=${proxsublimit_num:-500}
npredictors=${npredictors:-'NONE'}
num_predictors=${num_predictors:-0}
group1outcome=${group1outcome:-0}
group2outcome=${group2outcome:-0}
lowdensity=${lowdensity:-0.2}
stepdensity=${stepdensity:-0.05}
highdensity=${highdensity:-1}
infomapfile=${infomapfile:-'/group_shares/fnl/bulk/code/external/utilities/infomap/Infomap'}
infomap_nreps=${infomap_nreps:-10}
repopath=${repopath:-'/group_shares/fnl/bulk/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis'}
infomap_command_file=${infomap_command_file=:-'/group_shares/fnl/bulk/projects/FAIR_users/RFAnalysis/simple_infomap/simple_infomap.py'}
matlab_command=${matlab_command:-'matlab'}
modpath=${modpath:-'NONE'}
modvar=${modvar:-'NONE'}
grphmodpath=${grphmodpath:-'NONE'}
grphmodvar=${grphmodvar:-'NONE'}
dim_type=${dim_type:-'NONE'}
num_components=${num_components:-1}
systempath=${systempath:-'NONE'}
systemvar=${systemvar:-'NONE'}
edgedensity=${edgedensity:-0.05}
bctpath=${bctpath:-'/mnt/max/shared/code/external/utilities/BCT/'}

module load matlab
#Construct the model, which will save outputs to a filename.mat file
${matlab_command} -nodisplay -nosplash -singleCompThread -r "addpath('"${repopath}"') ; ConstructModelTreeBag(struct('path','"${group1path}"','variable','"${group1var}"'),"$group2_data","$datasplit","$nreps","$ntrees","$nperms",'"${filename}"',"$proxsublimit_num",'"${estimate_trees}"','"${weight_trees}"','"${trim_features}"',"$nfeatures",'"${OOB_error}"','"${fisher_z_transform}"','"${disable_treebag}"','"${holdout}"','"${holdout_data}"',"$group_holdout",'"${estimate_predictors}"','"${estimate_treepred}"','"${npredictors}"',"$num_predictors",'"${surrogate}"','"${regression}"','"${outcome_variable_exist}"',"$group1outcome","$group2outcome",'"${group2test}"','Prior','"${priors}"','"${unsupervised}"','"${matchgroups}"','LowDensity',"$lowdensity",'StepDensity',"$stepdensity",'HighDensity',"$highdensity",'"${cv}"',"$nfolds",'InfomapFile','"$infomapfile"','CommandFile','"$infomap_command_file"','"${reducedim}"',struct('path','"${modpath}"','variable','"${modvar}"'),'"${dim_type}"',"$num_components",'"${reducegraph}"',struct('path','"${systempath}"','variable','"${systemvar}"'),struct('path','"${grphmodpath}"','variable','"${grphmodvar}"'),"$edgedensity",'"${bctpath}"','"${reduceconnmat}"','InfomapNreps',"$infomap_nreps",'ShowMPath','"$showmpath"','GrammPath','"$grammpath"','"$gridsearch_flag"','"$gridsearch"','BCTPath','"$bct_path"','ConnectednessThreshold',"$connectedness_thresh"); exit"
