#!/bin/bash
excelfile=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Long_ADHD_OHSU/raw_data.xls #path and filename where the excel spreadsheet is located
output_matfile=LONG_ADHD_OHSU_dataset.mat #the name of the output (.mat) file.
exists_header=0 #if set to anything but 0 or blank, the first row of the excel file is a header and will be ignored
string_cols=[2 3 4] #a numeric vector encapsulated by square brackets, where each number denotes a column that represents a categorical variable, set to 0 if no such variable exists
type='surrogate' #sets whether the output contains rows with missing data ('surrogate') or excludes the rows ('no surrogate')
varname=group_data #the name of the variable saved to the .mat file
repopath=/group_shares/fnl/bulk/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis #the full path to the repository containing the RFAnalysis code.
matlab_command=matlab #the name of the matlab command line executable, can include arguments additional options, etc. SingleCompThread is enabled by default.
