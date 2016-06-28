#! /bin/bash

#ConstructModelTreeBag_wrapper.sh requires a ParamFile as an input (e.g. ConstructModelTreeBag_wrapper.sh TreeBagParamFile_example.bash). See the TreeBagParamFile_example.bash for more information on available parameters.
source $1
#parameters set from the TreeBagParamFile
if $use_group2_data; then group2_data="struct('path','"${group2path}"','variable','"${group2var}"')"; else group2_data=0; fi
if $estimate_trees; then estimate_trees='EstimateTrees'; else estimate_trees='NONE'; fi
if $weight_trees; then weight_trees='WeightForest'; else weight_trees='NONE'; fi
if $trim_features; then trim_features='TrimFeatures'; else trim_features='NONE'; fi
if $fisher_z_transform; then fisher_z_transform='FisherZ'; else fisher_z_transform='NONE'; fi
if $disable_treebag; then disable_treebag='TreebagsOff'; else disable_treebag='NONE'; fi
if $holdout; then holdout='Holdout'; else holdout='NONE'; fi
if $npredictors; then npredictors='npredictors'; else npredictors='NONE'; fi
if $estimate_predictors; then estimate_predictors='EstimatePredictors'; else estimate_predictors='NONE'; fi
if $regression; then regression='Regression'; if $outcome_is_struct; then group1outcome="struct('path','"${group1outcome_path}"','variable','"${group1outcome_var}"')"; group2outcome="struct('path','"${group2outcome_path}"','variable','"${group2outcome_var}"')"; else group1outcome=$group1outcome_num; group2outcome=$group2outcome_num; fi; else regression='NONE'; group1outcome=0; group2outcome=0; fi
if $surrogate; then surrogate='surrogate'; else surrogate='NONE'; fi
if $group2_validate_only; then group2test='group2istestdata'; else group2test='NONE'; fi
if $uniform_priors; then priors='Uniform'; else priors='Empirical'; fi
#If missing parameters, set defaults
datasplit=${datasplit:-0.9}
ntrees=${ntrees:-1000}
nreps=${nreps:-1000}
nperms=${nperms:-1}
filename=${filename:-'thenamelessone'}
estimate_trees=${estimate_trees:-'NONE'}
weight_trees=${weight_trees:-'NONE'}
trim_features=${trim_features:-'NONE'}
nfeatures=${nfeatures:-0}
fisher_z_transform=${fisher_z_transform:-'NONE'}
disable_treebag=${disable_treebag:-'TreebagsOff'}
holdout=${holdout:-'NONE'}
holdout_data=${holdout_data:-'NONE'}
group_holdout=${group_holdout:-0}
proxsublimit_num=${proxsublimit_num:-500}
npredictors=${npredictors:-'NONE'}
num_predictors=${num_predictors:-0}
estimate_predictors=${estimate_predictors:-'NONE'}
regression=${regression:-'NONE'}
surrogate=${surrogate:-'NONE'}
group2test=${group2test:-'NONE'}
group1outcome=${group1outcome:-0}
group2outcome=${group2outcome:-0}
#Construct the model, which will save outputs to a filename.mat file
matlab14b -nodisplay -nosplash -singleCompThread -r "addpath('/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Analysis') ; ConstructModelTreeBag(struct('path','"${group1path}"','variable','"${group1var}"'),"$group2_data","$datasplit","$nreps","$ntrees","$nperms",'"${filename}"',"$proxsublimit_num",'"${estimate_trees}"','"${weight_trees}"','"${trim_features}"',"$nfeatures",'"${fisher_z_transform}"','"${disable_treebag}"','"${holdout}"','"${holdout_data}"',"$group_holdout",'"${npredictors}"',"$num_predictors",'"${surrogate}"','"${regression}"',"$group1outcome","$group2outcome",'"${group2test}"','Prior','"${priors}"') ; exit"
