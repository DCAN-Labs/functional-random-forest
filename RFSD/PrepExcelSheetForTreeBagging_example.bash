#!/bin/bash

# path and filename where the excel spreadsheet is located
excelfile=./ExcelExampleSmall.xlsx

# the name of the output (.mat) file.
output_matfile=./ExcelExampleOutput.mat

# if set to anything but 0 or blank, the first row of the excel file is a
#   header and will be ignored
exists_header=1

# a numeric vector encapsulated by square brackets, where each number denotes
#   a column that represents a categorical variable, set to 0 if no such
#   variable exists
string_cols=[3]

# sets whether the output contains rows with missing data ('surrogate') or
#   excludes the rows ('no_surrogate')
type='no_surrogate'

# the name of the variable saved to the .mat file
varname=group_data

# the full path to the repository containing the RFAnalysis code.
repopath=/mnt/max/home/robinsph/git/Analysis/RFSD/

# the name of the matlab command line executable, can include arguments
#   additional options, etc. SingleCompThread is enabled by default.
matlab_command=matlab
