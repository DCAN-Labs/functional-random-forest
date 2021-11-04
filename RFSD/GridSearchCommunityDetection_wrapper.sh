#!/bin/bash
paramfile=$1; shift
GRID_program=$1; shift
GRID_files=$1; shift
matlab_command=$1; shift
if [[ -d ${GRID_files} ]]; then
  echo ${GRID_files} exists!
else
  mkdir ${GRID_files}
fi
LowDensityMin=`grep lowdensitymin= ${paramfile} | cut -f2 -d'=' | cut -f1 -d';'`
LowDensityStep=`grep lowdensitystep= ${paramfile} | cut -f2 -d'=' | cut -f1 -d';'`
LowDensityMax=`grep lowdensitymax= ${paramfile} | cut -f2 -d'=' | cut -f1 -d';'`
StepDensityMin=`grep stepdensitymin= ${paramfile} | cut -f2 -d'=' | cut -f1 -d';'`
StepDensityStep=`grep stepdensitystep= ${paramfile} | cut -f2 -d'=' | cut -f1 -d';'`
StepDensityMax=`grep stepdensitymax= ${paramfile} | cut -f2 -d'=' | cut -f1 -d';'`
HighDensityMin=`grep highdensitymin= ${paramfile} | cut -f2 -d'=' | cut -f1 -d';'`
HighDensityStep=`grep highdensitystep= ${paramfile} | cut -f2 -d'=' | cut -f1 -d';'`
HighDensityMax=`grep highdensitymax= ${paramfile} | cut -f2 -d'=' | cut -f1 -d';'`
output_directory=`grep output_directory= ${paramfile} | cut -f2 -d"'" | cut -f1 -d'{'`
if [[ -d ${output_directory} ]]; then 
  echo ${output_directory} exists!
else 
  mkdir ${output_directory}
fi
mkdir ${GRID_files}/sbatch_logs
for LowDensity in $(seq $LowDensityMin $LowDensityStep $LowDensityMax); do
  for StepDensity in $(seq $StepDensityMin $StepDensityStep $StepDensityMax); do
    for HighDensity in $(seq $HighDensityMin $HighDensityStep $HighDensityMax); do
      eval_density=`echo "$LowDensity<$HighDensity" | bc -l`
      if [[ $eval_density -eq 1 ]]; then
        new_output_root=`echo "GS_Low${LowDensity}_Step${StepDensity}_High${HighDensity}" | sed 's|\.|p|g'`
        mkdir ${output_directory}/${new_output_root}
        sed "s|{LOWDENSITY}|${LowDensity}|" <${paramfile} > ${GRID_files}/lowdensity_temp.m
        sed "s|{STEPDENSITY}|${StepDensity}|" <${GRID_files}/lowdensity_temp.m > ${GRID_files}/stepdensity_temp.m
        sed "s|{HIGHDENSITY}|${HighDensity}|" <${GRID_files}/stepdensity_temp.m > ${GRID_files}/highdensity_temp.m
        sed "s|{OUTPUT}|${new_output_root}|" <${GRID_files}/highdensity_temp.m > ${GRID_files}/${new_output_root}.m
        rm ${GRID_files}/*temp.m
        pushd ${GRID_files}
        echo ${GRID_files}/sbatch_logs/${new_output_root}.out
        echo ${GRID_files}/sbatch_logs/${new_output_root}.err
        echo ${GRID_program}/bin/run_GridSearchCommunityDetection.sh
        sbatch --job-name=${new_output_root} --output=${GRID_files}/sbatch_logs/${new_output_root}.out --error=${GRID_files}/sbatch_logs/${new_output_root}.err "$@" ${GRID_program}/run_GridSearchCommunityDetection.sh ${matlab_command} ${new_output_root}
        popd
        sleep 5
      fi
    done
  done
done