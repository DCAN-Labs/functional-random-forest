#! /bin/bash
#FunctionalRandomForest_wrapper.sh requires a ParamFile as an input (e.g. FunctionalRandomForest_wrapper.sh FunctionalRandomForest_example.bash). See the FunctionalRandomForest_example.bash for more information on available parameters.
source $1
#If missing parameters, set defaults
agecol=${agecol:-2}
idcol=${idcol:-1}
filename=${filename:-'thenamelessone'}
infomap_command_file=${infomap_command_file:-'/group_shares/fnl/bulk/code/internal/utilities/simple_infomap/simple_infomap.py'}
lowdensity=${lowdensity:-0.01}
stepdensity=${stepdensity:-0.05}
highdensity=${highdensity:-0.1}
corrtype=${corrtype:-'all'}
piecemeal=${piecemeal:-'false'}
EDA=${EDA:-'false'}
use_time_range=${use_time_range:-'false'}
low_time=${low_time:-8}
high_time=${high_time:-14}
time_range_flex=${time_range_flex:-0}
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
image_suffix=${image_suffix:-'.tif'}
infomapfile=${infomapfile:-'/group_shares/fnl/bulk/code/external/utilities/infomap/Infomap'}
repopath=${repopath:-'/group_shares/fnl/bulk/code/internal/analyses/RFAnalysis'}
matlab_command=${matlab_command:-'matlab'}
#Construct the model, which will save outputs to a filename.mat file
if $EDA; then EDAvar='EDA'; else EDAvar='NONE'; fi
if $piecemeal; then piecetype='piece'; sampling='piecewise_sampling'; else piecetype='full'; sampling='NONE'; fi
if $use_time_range; then time_range_var='time_range'; else time_range_var='NONE'; fi
mkdir $filename
${matlab_command} -nodisplay -nosplash -singleCompThread -r "addpath(genpath('"${repopath}"')) ; addpath(genpath('/group_shares/fnl/bulk/code/external/utilities/fdaM')) ; GenerateFDACoeffMatrix('"${dataspreadsheet}"',"${agecol}","${idcol}",'roundfactor',"${roundfactor}",'norder_data',"${norder_data}",'norder_error',"${norder_error}",'number_knots',"${number_knots}",'save_data',strcat('"${filename}"','/FDAcoeff_results.mat'),'"${EDAvar}"',[ "${low_trajectory}" "${high_trajectory}" ],'"${time_range_var}"',[ "${low_time}" "${high_time}" ],'time_range_flex',"${time_range_flex}",'"${sampling}"'); load(strcat('"$filename"','/FDAcoeff_results.mat')) ; GenerateTrajectoryCorrelationMatrix(struct('path',strcat('"${filename}"','/FDAcoeff_results.mat'),'variable','functional_data_group'),struct('path',strcat('"${filename}"','/FDAcoeff_results.mat'),'variable','subject_use_flag'),'"$filename"','"$corrtype"','"${piecetype}"',timebinmat) ; RunAndVisualizeCommunityDetection(struct('path',strcat('"${filename}"','/fda_corrmat.mat'),'variable','datafinecorrmat'),'"$filename"','"$infomap_command_file"',100,'LowDensity',"$lowdensity",'StepDensity',"$stepdensity",'HighDensity',"$highdensity",'"$infomapfile"'); load(strcat('"$filename"','/FDAcoeff_results.mat'),'subjects','subject_use_flag') ; subject_flag_thresh = sum(subject_use_flag,2)/size(subject_use_flag,2) == 1 ; useable_subjects = subjects(subject_flag_thresh) ; load(strcat('"$filename"','/final_community_assignments.mat')) ; save(strcat('"$filename"','/final_community_assignments.mat'),'useable_subjects','community','sorting_order') ; load(strcat('"$filename"','/FDAcoeff_results.mat')) ;  ConstructAllSubgroupTrajectories(functional_data_group,community,sparsedatamat,timemat,subject_use_flag,strcat('"$filename"','/subgroup_trajectories.mat'),'"${piecetype}"',timebinmat) ; MultiPlotFDACurves(strcat('"$filename"','/subgroup_trajectories.mat'),'/group_shares/fnl/bulk/code/internal/analyses/RFAnalysis/color_sets_FRF.mat',[ "$data_range_low" "$data_range_high" ],[ "$vis_range_low" "$vis_range_high" ],[ "$vel_range_low" "$vel_range_high" ],[ "$acc_range_low" "$acc_range_high" ],strcat('"$filename"','/trajectory_plot'),"$subject_threshold",'imagesuffix','"$image_suffix"') ; exit"
