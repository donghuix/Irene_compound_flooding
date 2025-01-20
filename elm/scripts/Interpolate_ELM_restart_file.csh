#!/bin/csh

#SBATCH --job-name=inter1        ## job_name
#SBATCH --partition=slurm
#SBATCH --account=esmd           ## project_name
#SBATCH --time=20:00:00          ## time_limit
#SBATCH --nodes=1                ## number_of_nodes
#SBATCH --ntasks-per-node=1      ## number_of_cores
#SBATCH --output=mat.stdout1     ## job_output_filename
#SBATCH --error=mat.stderr1      ## job_errors_filename

ulimit -s unlimited

module load intel/19.0.4
module load netcdf/4.7.4


cp mid_atlantic.elm.r.0031-08-26-00000_interpolated.nc mid_atlantic.IC_AMC_0.elm.r.2011-08-26-00000.nc
~/e3sm_lnd_ocn_two_way/components/elm/tools/interpinic/interpinic -i /compyfs/feng779/ensemble_uncertainty/ICs/IC_AMC_0.elm.r.2011-08-26-00000.nc \
                                                                  -o mid_atlantic.IC_AMC_0.elm.r.2011-08-26-00000.nc

cp mid_atlantic.elm.r.0031-08-26-00000_interpolated.nc mid_atlantic.IC_AMC_25.elm.r.2011-08-26-00000.nc
~/e3sm_lnd_ocn_two_way/components/elm/tools/interpinic/interpinic -i /compyfs/feng779/ensemble_uncertainty/ICs/IC_AMC_25.elm.r.2011-08-26-00000.nc \
                                                                  -o mid_atlantic.IC_AMC_25.elm.r.2011-08-26-00000.nc

cp mid_atlantic.elm.r.0031-08-26-00000_interpolated.nc mid_atlantic.IC_AMC_50.elm.r.2011-08-26-00000.nc
~/e3sm_lnd_ocn_two_way/components/elm/tools/interpinic/interpinic -i /compyfs/feng779/ensemble_uncertainty/ICs/IC_AMC_50.elm.r.2011-08-26-00000.nc \
                                                                  -o mid_atlantic.IC_AMC_50.elm.r.2011-08-26-00000.nc