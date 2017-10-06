#! /bin/bash
dataspreadsheet=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Analysis/example_data.xls #path and filename where excel spreadsheet of data is located. This should be in a long format (each timepoint from each subject is a different row)
agecol=2 #the column number for the variable containing the ages.
idcol=1 #the column number for the variable containing subject IDs
use_time_range=true #used to check subjects to make sure the first and last time points are acquired at the same time point, use the time_flex flag to force participants to have their curves registered to the anchor points
    low_time=8 #lowest time point measured (e.g. 8 years old)
    high_time=14 #highest time point measured (e.g. 14 years old)
    time_range_flex=1 #per case, this will register participants who do not have the lowest or highest time point measured but are within the range specified by the time_range_flex number -- use with extreme caution. Set to zero if you do not want to use it.
roundfactor=0 #the number of decimal places used to "bin" age. Default is to bin by integers (0).
norder_data=4 #the spline order for estimating data trajectories.
norder_error=2 #the spline order for estimating the penalties for the spline fits
number_knots=4 #the number of "knots" fixed points in the spline function that cannot be altered -- must be greater than two in order to provide anchors for the trajectory fit.
EDA=true # perform exploratory data analysis to rule out bad trajectory fits.
    low_trajectory=0 # if EDA is set to true, any trajectories that dip below this threshold will be excluded
    high_trajetory=140 # if EDA is set to true, any trajectories that dip above this threshold will be excluded
filename=example_trajectory_analysis #the name of the output directory
infomap_command_file=/group_shares/fnl/bulk/code/internal/utilities/simple_infomap/simple_infomap.py # the path and filename of the simple_infomap python function built by Damion Demeter
proximity_method=corr #Method for generating the proximity matrix. If set to "corr", will use a correlation trajectory approach. If set to "RF" will use an unsupervised algorithm approach
    corrtype=all #what metric should the correlation matrix be generated from? possible values are: dat (data), vel(velocity),acc(acceleration),all(data+velocity+acceleration)
lowdensity=0.05 #used for community detection -- the lowest edge density to examine community structure
stepdensity=0.01 #used for community detection -- the increment value for each edge density examined
highdensity=0.1 #used for community detection -- highest edge density to examine community structure

#multiplot viusalization options
vis_range_low=0 #low threshold for axis on trajectory plots
vis_range_high=70 #high threshold for axis on trajectory plots
data_range_low=0 #exclude data trajectories with fits that dip lower than this threshold
data_range_high=70 #exclude data trajectories with fits that bump higher than this threshold
vel_range_low=-10 #exclude velocity trajectories with fits that dip lower than this threshold
vel_range_high=10 #exclude velocity trajectories with fits that bump higher than this threshold
acc_range_low=-5 #exclude acceleration trajectories with fits that dip lower than this threshold
acc_range_high=5 #exclude acceleration trajectories with fits that bump higher than this threshold
subject_threshold=2 #plot trajectories for groups that have more members than this threshold

