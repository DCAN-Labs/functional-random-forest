#!/bin/bash
module load matlab
module load workbench
matlab_command=$1
parameter_file=$2
${matlab_command} -nodisplay -nosplash -r ${parameter_file}