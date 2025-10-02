# UFS Short-Range Weather Application

ARL prototype experiment for AQMv8_p1.2 with updated GFSv17 physics and spun-up land/soil conditions on Gaea C6.

Additional workaround to avoid mysterious libstdcxx-ng libarary errors with nexus_emissions task error on C6 below:

Before generating workflow run, follow steps to update libstdcxx-ng packages in base conda environment on C6.

module use /path/to/ufs-srweather-app/modulefiles
module load wflow_gaeac6

conda activate srw_app
conda activate base
conda update libstdcxx-ng
conda activate srw_app

cd ush
cp config.aqmv8_gaeac6.yaml config.yaml

./generate_FV3LAM_wflow.py


The Unified Forecast System (UFS) is a community-based, coupled, comprehensive Earth modeling system. NOAA's operational model suite for numerical weather prediction (NWP) is quickly transitioning to the UFS from a number of legacy modeling systems. The UFS enables research, development, and contribution opportunities within the broader Weather Enterprise (including government, industry, and academia). For more information about the UFS, visit the UFS Portal at https://ufs.epic.noaa.gov/.

The UFS includes multiple applications (see a complete list at https://ufs.epic.noaa.gov/applications/) that support different forecast durations and spatial domains. This documentation describes the development branch of the UFS Short-Range Weather (SRW) Application, which targets predictions of atmospheric behavior on a limited spatial domain and on time scales from minutes to several days. The development branch of the application is continually evolving as the system undergoes open development. The latest SRW App release (v2.2.0) represents a snapshot of this continuously evolving system. 

The UFS SRW App User's Guide associated with the development branch is at: https://ufs-srweather-app.readthedocs.io/en/develop/, while the guide specific to the SRW App v2.2.0 release can be found at: https://ufs-srweather-app.readthedocs.io/en/release-public-v2.2.0/. The repository is at: https://github.com/ufs-community/ufs-srweather-app.

For instructions on how to clone the repository, build the code, and run the workflow, see:
- https://ufs-srweather-app.readthedocs.io/en/develop/UsersGuide/BuildingRunningTesting/Quickstart.html

For a debugging guide for users and developers in the field of Earth System Modeling, please see:
https://epic.noaa.gov/wp-content/uploads/2022/12/Debugging-Guide.pdf

UFS Development Team. (2023, Oct. 31). Unified Forecast System (UFS) Short-Range Weather (SRW) Application (Version v2.2.0). Zenodo. https://doi.org/10.5281/zenodo.10015544

[![Python unittests](https://github.com/ufs-community/ufs-srweather-app/actions/workflows/python_unittests.yaml/badge.svg)](https://github.com/ufs-community/ufs-srweather-app/actions/workflows/python_unittests.yaml)
[![Python functional tests](https://github.com/ufs-community/ufs-srweather-app/actions/workflows/python_func_tests.yaml/badge.svg)](https://github.com/ufs-community/ufs-srweather-app/actions/workflows/python_func_tests.yaml)

