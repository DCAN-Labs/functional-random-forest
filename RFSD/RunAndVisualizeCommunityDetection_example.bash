#!/bin/bash

# N.B. if you are using correlation matrices with non-positive values, one
#   should determine beforehand what is the maximum density that only includes
#   positive values. It would not make sense to go above this in your
#   highdensity parameter below
# N.B. the variable within the .mat file must be a cell array. If you only
#   have a single 2D matrix variable, you should encapsulate it in a 1x1 cell
#   (e.g. corrmat={corrmat}) and resave your .mat file

# path and filename where group1's data is located
corrmatpath=./example_XCCvsUCC.mat

# the name of the variable within group1's matrix (.mat) file. This should
#   represent a (cell array that contains a) 2D matrix
corrmatvar=proxmat

# the name of the output directory
filename=example_XCCvsUCC_output

# the path and filename of the simple_infomap python wrapper
infomap_command_file=/mnt/max/home/robinsph/git/Analysis/simple_infomap/simple_infomap.py

# used for community detection -- the lowest edge density to examine
#   community structure
lowdensity=0.2

# used for community detection -- the increment value for each edge
#   density examined
stepdensity=0.05

# used for community detection -- highest edge density to examine
#   community structure
highdensity=1

# used for community detection -- number of infomap iterations
infomap_nreps=10

# the full path and filename for the Infomap executable, must be installed
#   from http://mapequation.org
infomapfile=/mnt/max/home/robinsph/git/infomap/Infomap

# the full path to the repository containing the RFAnalysis code.
repopath=/mnt/max/home/robinsph/git/Analysis/RFSD

# the name of the matlab command line executable, can include arguments
#   additional options, etc. SingleCompThread is enabled by default.
matlab_command=matlab
