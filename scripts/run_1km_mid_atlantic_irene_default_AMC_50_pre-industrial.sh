#!/bin/sh

RES=ELM_USRDAT
COMPSET=2000_DATM%MOSARTTEST_ELM%SPBC_SICE_SOCN_MOSART_SGLC_SWAV
MACH=pm-cpu
COMPILER=intel
PROJECT=m3780

DOMAIN_FILE_PATH=/global/cfs/projectdirs/m4267/shared/data/irene/delaware/elm/
DOMAIN_FILE=domain_mid_atlantic_c240907.nc
FSURDAT=/global/cfs/projectdirs/m4267/donghui/Irene_compound_flooding/inputdata/surface_dataset_mid_atlantic_c240907_default.nc

NTASKS=200
JOB_WALLCLOCK_TIME=10:00:00

SRC_DIR=/global/homes/d/donghui/e3sm_master
CASE_DIR=${SRC_DIR}/cime/scripts

cd ${SRC_DIR}

GIT_HASH=`git log -n 1 --format=%h`
CASE_NAME=mid_atlantic_1km_irene_default_AMC_50_pre-industrial.`date "+%Y-%m-%d-%H%M%S"`

cd ${SRC_DIR}/cime/scripts

./create_newcase -case ${CASE_DIR}/${CASE_NAME} \
-res ${RES} -mach ${MACH} -compiler ${COMPILER} -compset ${COMPSET} --project ${PROJECT}

cd ${CASE_DIR}/${CASE_NAME} 

./xmlchange LND_DOMAIN_FILE=$DOMAIN_FILE
./xmlchange ATM_DOMAIN_FILE=$DOMAIN_FILE
./xmlchange ATM_DOMAIN_PATH=$DOMAIN_FILE_PATH
./xmlchange LND_DOMAIN_PATH=$DOMAIN_FILE_PATH
./xmlchange CIME_OUTPUT_ROOT=/global/cfs/projectdirs/m4267/donghui/Irene_compound_flooding/outputs

./xmlchange PIO_VERSION=2
./xmlchange PIO_TYPENAME=pnetcdf
./xmlchange PIO_NETCDF_FORMAT=64bit_offset
./xmlchange NTASKS=$NTASKS
./xmlchange NTHRDS=1
./xmlchange PROJECT=$PROJECT

./xmlchange STOP_N=11,STOP_OPTION=ndays
./xmlchange RUN_STARTDATE=2011-08-26

./xmlchange DATM_MODE=CPLHIST
./xmlchange DATM_CPLHIST_YR_ALIGN=2011
./xmlchange DATM_CPLHIST_YR_START=2011
./xmlchange DATM_CPLHIST_YR_END=2011
./xmlchange DATM_CPLHIST_DIR=/global/cfs/cdirs/m3780/benedict/forDonghui/t46_v1.2-NATL-F2010C5-v2_L71.2011082512.ens012/run
./xmlchange DATM_CPLHIST_DOMAIN_FILE=${DOMAIN_FILE_PATH}${DOMAIN_FILE}
# Need to specify DATM_CPLHIST_DOMAIN_FILE=LND_DOMAIN_PATH/LND_DOMAIN_FILE
./xmlchange ATM_NCPL=96

./xmlchange JOB_WALLCLOCK_TIME=$JOB_WALLCLOCK_TIME


./xmlchange --file env_run.xml --id RUN_STARTDATE --val 2011-08-26

cat >> user_nl_elm << EOF
fsurdat = '$FSURDAT'
use_top_solar_rad  = .true.
use_modified_infil = .true.
finidat = '/global/cfs/projectdirs/m4267/donghui/Irene_compound_flooding/inputdata/mid_atlantic.IC_AMC_50.elm.r.2011-08-26-00000.nc'
hist_empty_htapes=.TRUE.
hist_fincl1 = 'QOVER','QRUNOFF','RAIN','FSAT','FH2OSFC','QDRAI'
hist_nhtfrq = -1
hist_mfilt = 24
EOF

# Since CPLHIST is on unstructured mesh, one cannot use bilinear interpolation.
# Or need to provide a mapping file. 
cat << EOF >> user_nl_datm
  dtlimit = 1.0e30, 1.0e30, 1.0e30, 1.0e30, 1.0e30, 1.0e30
  mapalgo = "nn", "nn", "nn", "nn", "nn", "nn"
EOF

cp /global/cfs/projectdirs/m4267/donghui/Irene_compound_flooding/scripts/datm_Jim_pre-industrial_ens012/* .

./case.setup
./case.build
./case.submit