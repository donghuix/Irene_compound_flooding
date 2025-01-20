#!/bin/bash

cp Delaware_vrm_xq2018.OceanDirichletBC.yaml AMC_000
cd AMC_000
sbatch Delaware_vrm_pm-gpu_xq2018_AMC_0.OceanDirichletBC.N_1.batch
cd ..

cp Delaware_vrm_xq2018.OceanDirichletBC.yaml AMC_025
cd AMC_025
sbatch Delaware_vrm_pm-gpu_xq2018_AMC_25.OceanDirichletBC.N_1.batch
cd ..

cp Delaware_vrm_xq2018.OceanDirichletBC.yaml AMC_050
cd AMC_050
sbatch Delaware_vrm_pm-gpu_xq2018_AMC_50.OceanDirichletBC.N_1.batch
cd ..

cp Delaware_vrm_xq2018.OceanDirichletBC.yaml AMC_075
cd AMC_075
sbatch Delaware_vrm_pm-gpu_xq2018_AMC_75.OceanDirichletBC.N_1.batch
cd ..

cp Delaware_vrm_xq2018.OceanDirichletBC.yaml AMC_100
cd AMC_100
sbatch Delaware_vrm_pm-gpu_xq2018_AMC_100.OceanDirichletBC.N_1.batch
cd ..
