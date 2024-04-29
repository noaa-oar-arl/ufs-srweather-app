#!/usr/bin/env bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${USHsrw}/source_util_funcs.sh
source_config_for_task "cpl_aqm_parm|task_nexus_gfs_sfc" ${GLOBAL_VAR_DEFNS_FP}
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -xue; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( $READLINK -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Entering script:  \"${scrfunc_fn}\"
In directory:     \"${scrfunc_dir}\"

This is the ex-script for the task that copies or fetches GFS surface
data files from disk or HPSS.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Set up variables for call to retrieve_data.py
#
#-----------------------------------------------------------------------
#
YYYYMMDD=${GFS_SFC_CDATE:0:8}
YYYYMM=${GFS_SFC_CDATE:0:6}
YYYY=${GFS_SFC_CDATE:0:4}
HH=${GFS_SFC_CDATE:8:2}

if [ ${#FCST_LEN_CYCL[@]} -gt 1 ]; then
  cyc_mod=$(( ${cyc} - ${DATE_FIRST_CYCL:8:2} ))
  CYCLE_IDX=$(( ${cyc_mod} / ${INCR_CYCL_FREQ} ))
  FCST_LEN_HRS=${FCST_LEN_CYCL[$CYCLE_IDX]}
fi
fcst_len_hrs_offset=$(( FCST_LEN_HRS + TIME_OFFSET_HRS ))
#
#-----------------------------------------------------------------------
#
# Retrieve GFS surface files
#
#-----------------------------------------------------------------------
#
GFS_SFC_TAR_DIR="${NEXUS_GFS_SFC_ARCHV_DIR}/rh${YYYY}/${YYYYMM}/${YYYYMMDD}"
GFS_SFC_TAR_SUB_DIR="gfs.${YYYYMMDD}/${HH}/atmos"

if [ "${DO_REAL_TIME}" = "TRUE" ]; then
  GFS_SFC_LOCAL_DIR="${COMINgfs}/${GFS_SFC_TAR_SUB_DIR}"
else
  GFS_SFC_LOCAL_DIR="${NEXUS_GFS_SFC_DIR}/${GFS_SFC_TAR_SUB_DIR}"
fi	

GFS_SFC_DATA_INTVL="3"

# copy files from local directory
if [ -d ${GFS_SFC_LOCAL_DIR} ]; then
  gfs_sfc_fn="gfs.t${HH}z.sfcanl.nc"

  gfs_sfc_fp="${GFS_SFC_LOCAL_DIR}/${gfs_sfc_fn}"
  ln -sf ${gfs_sfc_fp} ${DATA_SHARE}/${gfs_sfc_fn}

  for fhr in $(seq -f "%03g" 0 ${GFS_SFC_DATA_INTVL} ${fcst_len_hrs_offset}); do
    gfs_sfc_fn="gfs.t${HH}z.sfcf${fhr}.nc"
    if [ -e "${GFS_SFC_LOCAL_DIR}/${gfs_sfc_fn}" ]; then
      gfs_sfc_fp="${GFS_SFC_LOCAL_DIR}/${gfs_sfc_fn}"
      ln -nsf ${gfs_sfc_fp} ${DATA_SHARE}/${gfs_sfc_fn}
    else
      message_txt="SFC file for nexus emission for \"${cycle}\" does not exist in the directory:
  GFS_SFC_LOCAL_DIR = \"${GFS_SFC_LOCAL_DIR}\"
  gfs_sfc_fn = \"${gfs_sfc_fn}\""
      print_err_msg_exit "${message_txt}"
    fi	    
  done 
# retrieve files from HPSS
else
  if [ "${YYYYMMDD}" -lt "20220627" ]; then
    GFS_SFC_TAR_FN_VER="prod"
  elif [ "${YYYYMMDD}" -lt "20221129" ]; then
    GFS_SFC_TAR_FN_VER="v16.2"
  else
    GFS_SFC_TAR_FN_VER="v16.3"
  fi
  GFS_SFC_TAR_FN_PREFIX="com_gfs_${GFS_SFC_TAR_FN_VER}_gfs"
  GFS_SFC_TAR_FN_SUFFIX_A="gfs_nca.tar"
  GFS_SFC_TAR_FN_SUFFIX_B="gfs_ncb.tar"

  # Check if the sfcanl file exists in the staging directory
  gfs_sfc_tar_fn="${GFS_SFC_TAR_FN_PREFIX}.${YYYYMMDD}_${HH}.${GFS_SFC_TAR_FN_SUFFIX_A}"
  gfs_sfc_tar_fp="${GFS_SFC_TAR_DIR}/${gfs_sfc_tar_fn}"
  gfs_sfc_fns=("gfs.t${HH}z.sfcanl.nc")
  gfs_sfc_fps="./${GFS_SFC_TAR_SUB_DIR}/gfs.t${HH}z.sfcanl.nc"
  if [ "${fcst_len_hrs_offset}" -lt "40" ]; then
    ARCHV_LEN_HRS="${fcst_len_hrs_offset}"
  else
    ARCHV_LEN_HRS="39"
  fi
  for fhr in $(seq -f "%03g" 0 ${GFS_SFC_DATA_INTVL} ${ARCHV_LEN_HRS}); do
    gfs_sfc_fns+="gfs.t${HH}z.sfcf${fhr}.nc"
    gfs_sfc_fps+=" ./${GFS_SFC_TAR_SUB_DIR}/gfs.t${HH}z.sfcf${fhr}.nc"
  done

  # Retrieve data from A file up to fcst_len_hrs_offset=39
  htar -tvf ${gfs_sfc_tar_fp}
  htar -xvf ${gfs_sfc_tar_fp} ${gfs_sfc_fps}
  export err=$?
  if [ $err -ne 0 ]; then
    message_txt="htar file reading operation (\"htar -xvf ...\") failed."
    print_err_msg_exit "${message_txt}"
  fi

  # Retireve data from B file when fcst_len_hrs_offset>=40
  if [ "${fcst_len_hrs_offset}" -ge "40" ]; then
    gfs_sfc_tar_fn="${GFS_SFC_TAR_FN_PREFIX}.${YYYYMMDD}_${HH}.${GFS_SFC_TAR_FN_SUFFIX_B}"
    gfs_sfc_tar_fp="${GFS_SFC_TAR_DIR}/${gfs_sfc_tar_fn}"
    gfs_sfc_fns=()
    gfs_sfc_fps=""
    for fhr in $(seq -f "%03g" 42 ${GFS_SFC_DATA_INTVL} ${fcst_len_hrs_offset}); do
      gfs_sfc_fns+="gfs.t${HH}z.sfcf${fhr}.nc"
      gfs_sfc_fps+=" ./${GFS_SFC_TAR_SUB_DIR}/gfs.t${HH}z.sfcf${fhr}.nc"  
    done
    htar -tvf ${gfs_sfc_tar_fp}
    htar -xvf ${gfs_sfc_tar_fp} ${gfs_sfc_fps}
    export err=$?
    if [ $err -ne 0 ]; then
      message_txt="htar file reading operation (\"htar -xvf ...\") failed."
      print_err_msg_exit "${message_txt}"
    fi
  fi
  # Link retrieved files to staging directory
  ln -sf ${DATA}/${GFS_SFC_TAR_SUB_DIR}/gfs.*.nc ${DATA_SHARE}
fi

#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/function.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1
