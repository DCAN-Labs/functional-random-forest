#!/bin/bash

# path and filename where group1's data is located
group1path=ExcelExampleOutput.mat

# the name of the variable within group1's matrix (.mat) file. This should
#   represent a 2D matrix
group1var=group_data

# if set to true, the dataset for the second group will be specified in a
#   separate file, if set to false, the first group's dataset will be
#   randomly split into two groups. Set to false when doing regression
use_group2_data=false
    # path and filename where group2's data is located
    group2path=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Long_ADHD_OHSU/unrelated_MBM.mat
    # the name of the variable within group2's matrix (.mat) file
    group2var=U_CC

# the name of the output directory
filename=example_XCCvsUCC_output

# if set to true, the algorithm will model a regression forest for a
#   selected outcome variable.
regression=false

# the path and filename of the .mat variable where the results are stored
results_matfile=tump.mat # /mnt/max/home/robinsph/git/Analysis/CONSTRUCT_TREEBAGM/example_XCCvsUCC.mat

# the path and filename of the simple_infomap python function
infomap_command_file=/mnt/max/home/robinsph/git/simple_infomap/simple_infomap.py

# used for community detection -- the lowest edge density to examine community structure
lowdensity=0.5
# used for community detection -- the increment value for each edge density examined
stepdensity=0.1
# used for community detection -- highest edge density to examine community structure
highdensity=1

# the full path and filename for the Infomap executable, must be installed from http://mapequation.org
infomapfile=/mnt/max/home/robinsph/git/infomap/Infomap

# the full path to the repository containing the RFAnalysis code.
repopath=/mnt/max/home/robinsph/git/Analysis/RFSD

# the name of the matlab command line executable, can include arguments additional
#   options, etc. SingleCompThread is enabled by default.
matlab_command=matlab
