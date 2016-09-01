#! /bin/bash
group1path=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Long_ADHD_OHSU/MBM_all.mat #path and filename where group1's data is located
group1var=X_CC #the name of the variable within group1's matrix (.mat) file. This should represent a 2D matrix
use_group2_data=true #if set to true, the dataset for the second group will be specified in a separate file, if set to false, the first group's dataset will be randomly split into two groups. Set to false when doing regression
group2path=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Long_ADHD_OHSU/unrelated_MBM.mat #path and filename where group2's data is located
group2var=U_CC #the name of the variable within group2's matrix (.mat) file
filename=example_XCCvsUCC_output #the name of the output directory
regression=false # if set to true, the algorithm will model a regression forest for a selected outcome variable.
results_matfile=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Long_ADHD_OHSU/example_XCCvsUCC.mat # the path and filename of the .mat variable where the results are stored
infomap_command_file=/group_shares/PSYCH/code/release/utilities/simple_infomap/simple_infomap.py # the path and filename of the simple_infomap python function built by Damion Demeter
