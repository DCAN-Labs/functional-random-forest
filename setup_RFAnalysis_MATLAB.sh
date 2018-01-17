#! /bin/bash

#setup_RFAnalysis_MATLAB.sh will adjust wrapper scripts to use the matlab command
# Usage: setup_RFAnalysis_MATLAB.sh matlab16b matlab

old_matlab=$1
new_matlab=$2
for file in `ls *_wrapper.sh`; do sed 's/'$old_matlab'/'$new_matlab'/' <$file >${file}_new ; mv ${file}_new $file; done
