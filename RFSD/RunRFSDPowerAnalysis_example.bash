#! /bin/bash

# =====================
# == input and output parameters
# =====================

# path and filename where the input data are located
input_data=/mnt/max/home/robinsph/git/Analysis/DataFolder/EXCEL_PREP/ExcelExampleOutput.mat

# the name of the input variable stored in the .mat file
input_data_variable=group_data

# if set to true, a group_data column will be loaded as well
# XXX PMR : In order to do classification, we need a groupby column set to true
groupby=true
    # path and filename to where the group_column is stored can be same or
    #   different .mat file
    group_data=/mnt/max/home/robinsph/git/Analysis/DataFolder/CONSTRUCT_TREEBAGM/example_XCCvsUCC.mat
    # the name of the group variable stored in the .mat file
    group_data_variable=final_outcomes

# the name of the output prefix
output_directory=LONG_ADHD_OHSU_dataset

# a numeric vector encapsulated by square brackets, where each number denotes
#   a column that represents a categorical variable, set to 0 if no such
#   variable exists
categorical_vector=[3]

# =====================
# == dependency parameters
# =====================

# the full path to the repository containing the RFAnalysis code.
repopath=/mnt/max/home/robinsph/git/Analysis/RFSD/

# the name of the matlab command line executable, can include arguments
#   additional options, etc. SingleCompThread is enabled by default.
matlab_command=matlab

# the full path and filename for the Infomap executable, must be installed
#   from http://mapequation.org
infomapfile=/mnt/max/home/robinsph/git/infomap/Infomap
command_file=/mnt/max/home/robinsph/git/Analysis/simple_infomap/simple_infomap.py

# =====================
# == random forest parameters
# =====================

# sets whether a regression or classification RF is generated
forest_type='Classification'

# sets whether one is testing a supervised or unsupervised algorithm.
learning_type='supervised'

# if regression is selected, the number represents the column in the data
#   matrix containing the outcome measure
outcome_regression_column=0

# if zscore_flag is set to true, regression outcome variables will be z-scored
#   for simulated data
zscore_flag=true

# =====================
# == power analysis parameters
# =====================

# the sample size to simulate
num_sim_cases=100

# the number of simulations to run
num_sims=1000

# the thresholds for performance to use to calculate statistical power
performance_thresholds='0.4:0.1:0.8'

# =====================
# == parallel execution parameters
# =====================

# the number of cores to use for parallel execution
num_cores=1
