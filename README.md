# Irene_compound_flooding
This repo documents the scripts that use kilometer-scale E3SM to simulate compound flood induced by Hurricane Irene over Delaware River Basin.

## Compile River Dynamic Core ([RDycore](https://github.com/RDycore/RDycore)) on NERSC [Perlmutter](https://docs.nersc.gov/systems/perlmutter/architecture/)\
```
git clone git@github.com:RDycore/RDycore.git RDycore
cd RDycore
git submodule update --init
source config/set_petsc_settings.sh --mach pm-cpu --config 3
mkdir build-$PETSC_ARCH
cd build-$PETSC_ARCH
cmake .. -DCMAKE_INSTALL_PREFIX=$PWD -DCMAKE_BUILD_TYPE=Debug
make -j4 install
```
## E3SM Simulation
## RDycore Simulation
1. Historical 
    - Ensemble runoff forcing with different ELM Initial Condition (IC)
    - MPAS-O simulated water level as Boundary Condition (BC)
    - [NLCD](https://www.usgs.gov/centers/eros/science/national-land-cover-database) derived Manning Coefficient
2. Pre-industrial 
    - TODO: how to use mean sea-level to perturb BC
    - TODO: how to perturb land use and land cover

3. Future
    - TODO: how to use projected mean sea-level to perturb BC, maybe 0.5m, 0.75m, 1m?
    - TODO: how to perturb land use and land cover
## Benchmark
Satellite inundation observation: https://global-flood-database.cloudtostreet.info/#interactive-map

hire-ensemble8: calibrate Manning coefficient
hire-ensemble6: test AMC conditions 