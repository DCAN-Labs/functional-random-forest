#!/bin/bash
#VisualizeTreeBaggingResults_wrapper.sh requires a ParamFile as an input (e.g. VisualizeTreeBaggingResults_wrapper.sh VisualizeTreeBagResults_example.bash). See the VisualizeTreeBagResults_example.bash for more information on available parameters.
source $1
#parameters set from the VisualizeTreeBagResultsParamFile
#If missing parameters, set defaults
excelfile=${excelfile:-'thenamelessone'}
output_matfile=${output_matfile:-'group_data'}
exists_header=${exists_header:-0}
repopath=${repopath:-'/group_shares/fnl/bulk/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis'}
matlab_command=${matlab_command:-'matlab'}
varname=${varname:-'group_data'}
type=${type:-'surrogate'}
stringcols=${stringcols:-0}
#Construct the model, which will save outputs to a filename.mat file
${matlab_command} -nodisplay -nosplash -singleCompThread -r "addpath('"${repopath}"') ; PrepExcelSheetForTreeBagging('"$excelfile"','"$output_matfile"',"$exists_header","$string_cols",'"$type"','DataName','"$varname"'); exit"
