#!/bin/bash
fdapath=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Long_ADHD_OHSU/MBM_all.mat #path and filename where group1's data is located
fdavar=X_CC #the name of the variable within group1's matrix (.mat) file. This should represent a 2D matrix
subjectspath=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Long_ADHD_OHSU/MBM_all.mat #path and filename where group1's data is located
subjectsvar=X_CC #the name of the variable within group1's matrix (.mat) file. This should represent a 2D matrix
filename=example_XCCvsUCC_output #the name of the output directory
infomap_command_file=/group_shares/PSYCH/code/release/utilities/simple_infomap/simple_infomap.py # the path and filename of the simple_infomap python function built by Damion Demeter
lowdensity=0.2 #used for community detection -- the lowest edge density to examine community structure
stepdensity=0.05 #used for community detection -- the increment value for each edge density examined
highdensity=1 #used for community detection -- highest edge density to examine community structure
corrtype=dat #what metric should the correlation matrix be generated from? possible values are: dat (data), vel(velocity),acc(acceleration),all(data+velocity+acceleration
