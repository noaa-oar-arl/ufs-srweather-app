#!/usr/bin/env bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${USHsrw}/source_util_funcs.sh
source_config_for_task "cpl_aqm_parm|task_run_post|task_post_stat_pm25" ${GLOBAL_VAR_DEFNS_FP}
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

This is the ex-script for the task that runs POST-STAT-PM25.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Set run command.
#
#-----------------------------------------------------------------------
#
eval ${PRE_TASK_CMDS}

if [ -z "${RUN_CMD_SERIAL:-}" ] ; then
  print_err_msg_exit "\
  Run command was not set in machine file. \
  Please set RUN_CMD_SERIAL for your platform"
else
  RUN_CMD_SERIAL=$(eval echo ${RUN_CMD_SERIAL})
  print_info_msg "$VERBOSE" "
  All executables will be submitted with command \'${RUN_CMD_SERIAL}\'."
fi
#
#-----------------------------------------------------------------------
#
# POST-STAT: PM25
#
#-----------------------------------------------------------------------
#

if [ "${PREDEF_GRID_NAME}" = "AQM_NA_13km" ]; then
  id_domain=793
fi

#---------------------------------------------------------------
# aqm_pm25_post
#---------------------------------------------------------------

ln -sf ${COMIN}/${cyc}/${NET}.${cycle}.chem_sfc.nc .

cat >aqm_post.ini <<EOF1
&control
varlist='PM25_TOT'
infile='${NET}.${cycle}.chem_sfc.nc'
outfile='${NET}.${cycle}.pm25'
id_gribdomain=${id_domain}
/
EOF1

# convert from netcdf to grib2 format
PREP_STEP
eval ${RUN_CMD_SERIAL} ${EXECdir}/aqm_post_grib2 ${PDY} ${cyc} ${REDIRECT_OUT_ERR}
export err=$?
  err_chk
POST_STEP

cat ${NET}.${cycle}.pm25.*.${id_domain}.grib2 >> ${NET}.${cycle}.1hpm25.${id_domain}.grib2

export grid227="lambert:265.0000:25.0000:25.0000 226.5410:1473:5079.000 12.1900:1025:5079.000"
#export grid148="lambert:263.0000:33.0000:45.0000 239.3720:442:12000.000 21.8210:265:12000.000"
export grid196="mercator:20.0000 198.4750:321:2500.000:206.1310 18.0730:255:2500.000:23.0880"
export grid198="nps:210.0000:60.0000 181.4290:825:5953.000 40.5300:553:5953.000"

for grid in 227 196 198; do
  gg="grid${grid}"
  wgrib2 ${NET}.${cycle}.1hpm25.${id_domain}.grib2 -set_grib_type c3b -new_grid_winds earth -new_grid ${!gg} ${NET}.${cycle}.1hpm25.${grid}.grib2
done

cp ${DATA}/${NET}.${cycle}*pm25*.grib2 ${COMOUT}
  
# Create AWIPS GRIB2 data for Bias-Corrected PM2.5
if [ "${cyc}" = "06" ] || [ "${cyc}" = "12" ]; then
  for grid in 227 198 196; do
    echo 0 > filesize
    export XLFRTEOPTS="unit_vars=yes"
    export FORT11=${NET}.${cycle}.1hpm25.${grid}.grib2
    export FORT12="filesize"
    export FORT31=
    export FORT51=${NET}.${cycle}.1hpm25.${grid}.grib2.temp
    tocgrib2super < ${PARMdir}/aqm_utils/wmo/grib2_aqm_1hpm25.${cycle}.${grid}
				
    echo `ls -l ${NET}.${cycle}.grib2_pm25.${grid}.temp  | awk '{print $5} '` > filesize
    export XLFRTEOPTS="unit_vars=yes"
    export FORT11=${NET}.${cycle}.1hpm25.${grid}.grib2.temp
    export FORT12="filesize"
    export FORT31=
    export FORT51=awpaqm.${cycle}.1hpm25.${grid}.grib2
    tocgrib2super < ${PARMdir}/aqm_utils/wmo/grib2_aqm_1hpm25.${cycle}.${grid}

    # Post Files to COMOUTwmo
    cp awpaqm.${cycle}.1hpm25.${grid}.grib2 ${COMOUTwmo}

    # Distribute Data
#    if [ "${SENDDBN_NTC}" = "TRUE" ] ; then
#      ${DBNROOT}/bin/dbn_alert ${DBNALERT_TYPE} ${NET} ${job} ${COMOUTwmo}/awpaqm.${cycle}.1hpm25.${grid}.grib2 
#      ${DBNROOT}/bin/dbn_alert ${DBNALERT_TYPE} ${NET} ${job} ${COMOUTwmo}/awpaqm.${cycle}.daily-1hr-pm25-max.${grid}.grib2
#    fi
  done
fi

#---------------------------------------------------------------
# aqm_pm25_post_maxi
#---------------------------------------------------------------
if [ "${cyc}" = "06" ] || [ "${cyc}" = "12" ]; then

  ln -sf ${COMIN}/${cyc}/${NET}.${cycle}.chem_sfc.nc a.nc

  export chk=1
  export chk1=1
  # today 00z file exists otherwise chk=0

cat >aqm_max.ini <<EOF1
&control
varlist='pm25_24h_ave','pm25_1h_max'
outfile='aqm_pm25_24h_ave'
id_gribdomain=${id_domain}
max_proc=72
/
EOF1

  flag_run_bicor_max=yes
  # 06z needs b.nc to find current day output from 04Z to 06Z
  if [ "${cyc}" = "06" ]; then
    if [ -s ${COMIN}/00/${NET}.t00z.chem_sfc.nc ]; then
      ln -sf  ${COMIN}/00/${NET}.t00z.chem_sfc.nc b.nc
    elif [ -s ${COMINm1}/12/${NET}.t12z.chem_sfc.nc ]; then
      ln -sf ${COMINm1}/12/${NET}.t12z.chem_sfc.nc b.nc
      chk=0
    else
      flag_run_bicor_max=no
    fi
  fi

  if [ "${cyc}" = "12" ]; then
    # 12z needs b.nc to find current day output from 04Z to 06Z
    if [ -s ${COMIN}/00/${NET}.t00z.chem_sfc.nc ]; then
      ln -sf ${COMIN}/00/${NET}.t00z.chem_sfc.nc b.nc
    elif [ -s ${COMINm1}/12/${NET}.t12z.chem_sfc.nc ]; then
      ln -sf ${COMINm1}/12/${NET}.${PDYm1}.t12z.chem_sfc.nc b.nc
      chk=0
    else
      flag_run_bicor_max=no
    fi

    # 12z needs c.nc to find current day output from 07Z to 12z
    if [ -s ${COMIN}/06/${NET}.t06z.chem_sfc.nc ]; then
      ln -sf ${COMIN}/06/${NET}.t06z.chem_sfc.nc c.nc
    elif [ -s ${COMINm1}/12/${NET}.t12z.chem_sfc.nc ]; then
      ln -sf ${COMINm1}/12/${NET}.t12z.chem_sfc.nc c.nc
      chk1=0
    else
      flag_run_bicor_max=no
    fi
  fi

  PREP_STEP
  eval ${RUN_CMD_SERIAL} ${EXECdir}/aqm_post_maxi_grib2 ${PDY} ${cyc} ${chk} ${chk1} ${REDIRECT_OUT_ERR}
  export err=$?
    err_chk
  POST_STEP

  wgrib2 ${NET}_pm25_24h_ave.${id_domain}.grib2 |grep "PMTF" | wgrib2 -i ${NET}_pm25_24h_ave.${id_domain}.grib2 -grib ${NET}.${cycle}.ave_24hr_pm25.${id_domain}.grib2
  wgrib2 ${NET}_pm25_24h_ave.${id_domain}.grib2 |grep "PDMAX1" | wgrib2 -i ${NET}_pm25_24h_ave.${id_domain}.grib2 -grib ${NET}.${cycle}.max_1hr_pm25.${id_domain}.grib2

  export grid227="lambert:265.0000:25.0000:25.0000 226.5410:1473:5079.000 12.1900:1025:5079.000"
  #export grid148="lambert:263.0000:33.0000:45.0000 239.3720:442:12000.000 21.8210:265:12000.000"
  export grid196="mercator:20.0000 198.4750:321:2500.000:206.1310 18.0730:255:2500.000:23.0880"
  export grid198="nps:210.0000:60.0000 181.4290:825:5953.000 40.5300:553:5953.000"

  for grid in 227 196 198; do
    gg="grid${grid}"
    wgrib2 ${NET}.${cycle}.ave_24hr_pm25.${id_domain}.grib2 -set_grib_type c3b -new_grid_winds earth -new_grid ${!gg} ${NET}.${cycle}.24hrpm25-ave.${grid}.grib2
    wgrib2 ${NET}.${cycle}.max_1hr_pm25.${id_domain}.grib2 -set_grib_type c3b -new_grid_winds earth -new_grid ${!gg} ${NET}.${cycle}.1hpm25-max.${grid}.grib2

    # Add WMO header for daily 1h PM2.5 and 24hr_ave PM2.5
    rm -f filesize
    echo 0 > filesize
    export XLFRTEOPTS="unit_vars=yes"
    export FORT11=${NET}.${cycle}.1hpm25-max.${grid}.grib2
    export FORT12="filesize"
    export FORT31=
    export FORT51=${NET}.${cycle}.max_1hr_pm25.${grid}.grib2.temp
    tocgrib2super < ${PARMdir}/aqm_utils/wmo/grib2_aqm_max_1hr_pm25.${cycle}.${grid}

    echo `ls -l  ${NET}.${cycle}.max_1hr_pm25.${grid}.grib2.temp | awk '{print $5} '` > filesize
    export XLFRTEOPTS="unit_vars=yes"
    export FORT11=${NET}.${cycle}.max_1hr_pm25.${grid}.grib2.temp
    export FORT12="filesize"
    export FORT31=
    export FORT51=awpaqm.${cycle}.daily-1hr-pm25-max.${grid}.grib2
    tocgrib2super < ${PARMdir}/aqm_utils/wmo/grib2_aqm_max_1hr_pm25.${cycle}.${grid}

    rm -f filesize
    echo 0 > filesize
    export XLFRTEOPTS="unit_vars=yes"
    export FORT11=${NET}.${cycle}.24hrpm25-ave.${grid}.grib2
    export FORT12="filesize"
    export FORT31=
    export FORT51=${NET}.${cycle}.24hrpm25-ave.${grid}.grib2.temp
    tocgrib2super < ${PARMdir}/aqm_utils/wmo/grib2_aqm_ave_24hrpm25_awp.${cycle}.${grid}

    echo `ls -l  ${NET}.${cycle}.24hrpm25-ave.${grid}.grib2.temp | awk '{print $5} '` > filesize
    export XLFRTEOPTS="unit_vars=yes"
    export FORT11=${NET}.${cycle}.24hrpm25-ave.${grid}.grib2.temp
    export FORT12="filesize"
    export FORT31=
    export FORT51=awpaqm.${cycle}.24hr-pm25-ave.${grid}.grib2
    tocgrib2super < ${PARMdir}/aqm_utils/wmo/grib2_aqm_ave_24hrpm25_awp.${cycle}.${grid}
    
    cp ${DATA}/${NET}.${cycle}.ave_24hr_pm25*.grib2 ${COMOUT}
    cp ${DATA}/${NET}.${cycle}.max_1hr_pm25*.grib2 ${COMOUT}
    cp awpaqm.${cycle}.daily-1hr-pm25-max.${grid}.grib2 ${COMOUTwmo}
    cp awpaqm.${cycle}.24hr-pm25-ave.${grid}.grib2 ${COMOUTwmo}

    ##############################
    # Distribute Data
    ##############################

    if [ "${SENDDBN_NTC}" = "TRUE" ] ; then
      ${DBNROOT}/bin/dbn_alert ${DBNALERT_TYPE} ${NET} ${job} ${COMOUTwmo}/awpaqm.${cycle}.1hpm25.${grid}.grib2 
      ${DBNROOT}/bin/dbn_alert ${DBNALERT_TYPE} ${NET} ${job} ${COMOUTwmo}/awpaqm.${cycle}.daily-1hr-pm25-max.${grid}.grib2
    fi

    if [ "$SENDDBN" = "TRUE" ]; then
      ${DBNROOT}/bin/dbn_alert MODEL AQM_PM ${job} ${COMOUTwmo}/awpaqm.${cycle}.24hr-pm25-ave.${grid}.grib2
      ${DBNROOT}/bin/dbn_alert MODEL AQM_MAX ${job} ${COMOUTwmo}/awpaqm.${cycle}.daily-1hr-pm25-max.${grid}.grib2
    fi
  done
fi
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
POST-STAT-PM25 completed successfully.

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1
