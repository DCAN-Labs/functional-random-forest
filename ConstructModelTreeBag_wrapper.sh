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
ntrees=$1;shift;
nreps=$1;shift;
nperms=$1;shift;
filename=$1;shift;
estimate_trees=$1;shift;
weight_trees=$1;shift;
#If missing parameters, set defaults
datasplit=${datasplit:-0.9}
ntrees=${ntrees:-500}
nreps=${nreps:-1000}
nperms=${nperms:-1}
filename=${filename:-'thenamelessone'}
estimate_trees=${estimate_trees:-'EstimateTrees'}
weight_trees=${weight_trees:-'WeightForest'}
#Construct the model, which will save outputs to a filename.mat file
matlab14b -nojvm -nodisplay -nosplash -singleCompThread -r "addpath('/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Analysis') ; ConstructModelTreeBag(struct('path','"${group1path}"','variable','"${group1var}"'),struct('path','"${group2path}"','variable','"${group2var}"'),"$datasplit","$ntrees","$nreps","$nperms",'"${filename}"','"${estimate_trees}"','"${weight_trees}"') ; exit"
