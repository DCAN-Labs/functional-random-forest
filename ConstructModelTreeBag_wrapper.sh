#! /bin/bash

#required parameters: 
#groupxpath is the full path to the .mat file storing the groupx data
#groupxvar is the name of the variable within the .mat file that stores groupx data
group1path=$1;shift;
group1var=$1;shift;
group2path=$1;shift;
group2var=$1;shift;
#optional parameters, defaults are given below
datasplit=$1;shift;
nreps=$1;shift;
ntrees=$1;shift;
nperms=$1;shift;
filename=$1;shift;
estimate_trees=$1;shift;
weight_trees=$1;shift;
trim_features=$1;shift;
nfeatures=$1;shift;
fisher_z_transform=$1;shift;
disable_treebag=$1;shift;
holdout=$1;shift;
holdout_data=$1;shift;
group_holdout=$1;shift;
proxsublimit_set=$1;shift;
proxsublimit_num=$1;shift;
#If missing parameters, set defaults
datasplit=${datasplit:-0.9}
ntrees=${ntrees:-1000}
nreps=${nreps:-1000}
nperms=${nperms:-1}
filename=${filename:-'thenamelessone'}
estimate_trees=${estimate_trees:-'EstimateTrees'}
weight_trees=${weight_trees:-'WeightForest'}
trim_features=${trim_features:-'blah'}
nfeatures=${nfeatures:-0}
fisher_z_transform=${fisher_z_transform:-'blahblahblah'}
disable_treebag=${disable_treebag:-'TreebagsOff'}
holdout=${holdout:-'yada'}
holdout_data=${holdout_data:-'yadayada'}
group_holdout=${group_holdout:-0}
proxsublimit_set=${proxsublimit_set:-'ProximitySubLimit'}
proxsublimit_num=${proxsublimit_num:-500}
#Construct the model, which will save outputs to a filename.mat file
matlab14b -nojvm -nodisplay -nosplash -singleCompThread -r "addpath('/group_shares/PSYCH/code/testing/analyses/treebag') ; ConstructModelTreeBag(struct('path','"${group1path}"','variable','"${group1var}"'),struct('path','"${group2path}"','variable','"${group2var}"'),"$datasplit","$nreps","$ntrees","$nperms",'"${filename}"','"${estimate_trees}"','"${weight_trees}"','"${trim_features}"',"$nfeatures",'"${fisher_z_transform}"','"${disable_treebag}"','"${holdout}"','"${holdout_data}"',"$group_holdout",'"${proxsublimit_set}"',"$proxsublimit_num") ; exit"
