#!/usr/bin/env bash
export GLOBAL_VAR_DEFNS_FP="${EXPTDIR}/var_defns.sh"
set -xa
source ${GLOBAL_VAR_DEFNS_FP}

export CDATE=${DATE_FIRST_CYCL}
export CYCLE_DIR=${EXPTDIR}/${CDATE}
${JOBSdir}/JREGIONAL_MAKE_OROG
