#! /bin/bash
#FunctionalRandomForest_wrapper.sh requires a ParamFile as an input (e.g. FunctionalRandomForest_wrapper.sh FunctionalRandomForest_example.bash). See the FunctionalRandomForest_example.bash for more information on available parameters.
source $1
#If missing parameters, set defaults
agecol=${agecol:-2}
idcol=${idcol:-1}
filename=${filename:-'thenamelessone'}
infomap_command_file=${infomap_command_file:-'/group_shares/PSYCH/code/release/utilities/simple_infomap/simple_infomap.py'}
lowdensity=${lowdensity:-0.01}
stepdensity=${stepdensity:-0.05}
highdensity=${highdensity:-0.1}
corrtype=${corrtype:-'all'}
EDA=${EDA:-'false'}
low_trajectory=${low_trajectory:-0}
high_trajectory=${high_trajectory:-140}
proximity_method=${proximity_method:-'corr'}
roundfactor=${roundfactor:-0}
norder_data=${norder_data:-6}
norder_error=${norder_error:-3}
number_knots=${number_knots:-4}
subject_threshold=${subject_threshold:-2}
vis_range_low=${vis_range_low:-0}
vis_range_high=${vis_range_high:-70}
data_range_low=${data_range_low:-0}
data_range_high=${data_range_high:-70}
vel_range_low=${vel_range_low:-0}
vel_range_high=${vel_range_high:-10}
acc_range_low=${acc_range_low:-0}
acc_range_high=${acc_range_high:-5}
#Construct the model, which will save outputs to a filename.mat file
if $EDA; then EDAvar='EDA'; else EDAvar='NONE'; fi
mkdir $filename
matlab14b -nodisplay -nosplash -singleCompThread -r "addpath(genpath('/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Analysis')) ; addpath(genpath('/group_shares/PSYCH/code/external/utilities/fdaM')) ; GenerateFDACoeffMatrix('"${dataspreadsheet}"',"${agecol}","${idcol}",'roundfactor',"${roundfactor}",'norder_data',"${norder_data}",'norder_error',"${norder_error}",'number_knots',"${number_knots}",'save_data',strcat('"${filename}"','/FDAcoeff_results.mat'),'"${EDAvar}"',[ "${low_trajectory}" "${high_trajectory}" ]} ; GenerateTrajectoryCorrelationMatrix(struct('path',strcat('"${filename}"','/FDAcoeff_results.mat'),'variable','functional_data_group'),struct('path',strcat('"${filename}"','/FDAcoeff_results.mat'),'variable','subject_use_flag'),strcat('"$filename"','/datafine_correlation_matrix.mat'),'"$corrtype"') ; RunAndVisualizeCommunityDetection(struct('path',strcat('"${filename}"','/datafine_correlation_matrix.mat'),'variable','datafinecorrmat'),'"$filename"','"$infomap_command_file"',100,'LowDensity',"$lowdensity",'StepDensity',"$stepdensity",'HighDensity',"$highdensity"); load(strcat('"$filename"','/FDAcoeff_results.mat')) ; load('"$filename"','/final_community_assignments.mat') ; ConstructAllSubgroupTrajectories(functional_data_group,community,sparsedatamat,timemat,subject_use_flag,strcat('"$filename"','/subgroup_trajectories.mat')) ; MultiPlotFDACurves(strcat('"$filename"','/subgroup_trajectories.mat'),'/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Analysis/color_sets_FRF.mat',[ "$data_range_low" "$data_range_high" ],[ "$vis_range_low" "$vis_range_high" ],[ "$vel_range_low" "$vel_range_high" ],[ "$acc_range_low" "$acc_range_high" ],strcat('"$filename"','/trajectory_plot'),"$subject_threshold") ; exit"
