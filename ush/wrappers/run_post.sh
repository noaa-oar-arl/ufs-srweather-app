#!/usr/bin/env bash
export GLOBAL_VAR_DEFNS_FP="${EXPTDIR}/var_defns.sh"
set -xa
source ${GLOBAL_VAR_DEFNS_FP}
export CDATE=${DATE_FIRST_CYCL}
export CYCLE_DIR=${EXPTDIR}/${CDATE}
export cyc=${DATE_FIRST_CYCL:8:2}
export PDY=${DATE_FIRST_CYCL:0:8}
export SLASH_ENSMEM_SUBDIR=""
export ENSMEM_INDX=""

num_fcst_hrs=${FCST_LEN_HRS}
for (( i=0; i<=$((num_fcst_hrs)); i++ )); do
  export fhr=`printf "%03i" ${i}`
  ${JOBSdir}/JREGIONAL_RUN_POST
done
