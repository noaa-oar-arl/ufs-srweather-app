help([[
This module loads libraries for building the UFS SRW App on
the NOAA RDHPC machine Hera using Intel-2022.1.2
]])

whatis([===[Loads libraries needed for building the UFS SRW App on Hera ]===])

prepend_path("MODULEPATH","/contrib/sutils/modulefiles")
load("sutils")

prepend_path("MODULEPATH", "/scratch1/NCEPDEV/nems/role.epic/spack-stack/spack-stack-1.4.1/envs/unified-env/install/modulefiles/Core")
prepend_path("MODULEPATH", "/scratch1/NCEPDEV/jcsda/jedipara/spack-stack/modulefiles")

stack_intel_ver=os.getenv("stack_intel_ver") or "2021.5.0"
load(pathJoin("stack-intel", stack_intel_ver))

stack_impi_ver=os.getenv("stack_impi_ver") or "2021.5.1"
load(pathJoin("stack-intel-oneapi-mpi", stack_impi_ver))

stack_python_ver=os.getenv("stack_python_ver") or "3.9.12"
load(pathJoin("stack-python", stack_python_ver))

cmake_ver=os.getenv("cmake_ver") or "3.20.1"
load(pathJoin("cmake", cmake_ver))

load("srw_common")

load(pathJoin("nccmp", os.getenv("nccmp_ver") or "1.9.0.1"))
load(pathJoin("nco", os.getenv("nco_ver") or "4.9.3"))
load("ufs-pyenv")

setenv("CMAKE_C_COMPILER","mpiicc")
setenv("CMAKE_CXX_COMPILER","mpiicpc")
setenv("CMAKE_Fortran_COMPILER","mpiifort")
setenv("CMAKE_Platform","hera.intel")
