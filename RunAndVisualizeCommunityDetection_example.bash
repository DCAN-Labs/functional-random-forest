#! /bin/bash

#N.B. if you are using correlation matrices with non-positive values, one should determine beforehand what is the maximum density that only includes positive values. It would not make sense to go above this in your highdensity parameter below
#N.B. the variable within the .mat file must be a cell array. If you only have a single 2D matrix variable, you should encapsulate it in a 1x1 cell (e.g. corrmat={corrmat}) and resave your .mat file

corrmatpath=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Long_ADHD_OHSU/MBM_all.mat #path and filename where group1's data is located
corrmatvar=X_CC #the name of the variable within group1's matrix (.mat) file. This should represent a (cell array that contains a) 2D matrix
filename=example_XCCvsUCC_output #the name of the output directory
infomap_command_file=/group_shares/fnl/bulk/code/internal/utilities/simple_infomap/simple_infomap.py # the path and filename of the simple_infomap python function built by Damion Demeter
lowdensity=0.2 #used for community detection -- the lowest edge density to examine community structure
stepdensity=0.05 #used for community detection -- the increment value for each edge density examined
highdensity=1 #used for community detection -- highest edge density to examine community structure
