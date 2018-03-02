#!/bin/bash
excelfile=./ExcelExampleSmall.xlsx #path and filename where the excel spreadsheet is located
output_matfile=./ExcelExampleOutput.mat #the name of the output (.mat) file.
exists_header=1 #if set to anything but 0 or blank, the first row of the excel file is a header and will be ignored
string_cols=[3] #a numeric vector encapsulated by square brackets, where each number denotes a column that represents a categorical variable, set to 0 if no such variable exists
type='no_surrogate' #sets whether the output contains rows with missing data ('surrogate') or excludes the rows ('no_surrogate')
varname=group_data #the name of the variable saved to the .mat file
repopath=/mnt/max/home/robinsph/git/Analysis/RFSD/ #the full path to the repository containing the RFAnalysis code.
matlab_command=matlab #the name of the matlab command line executable, can include arguments additional options, etc. SingleCompThread is enabled by default.
