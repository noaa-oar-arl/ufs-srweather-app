help([[
This module loads libraries for building the UFS SRW App on
the GMU ORC machine Hopper using GNU 10.3
]])

whatis([===[Loads libraries needed for building the UFS SRW App on Hopper using GNU 10.3 ]===])

-- prepend_path("MODULEPATH","/contrib/sutils/modulefiles")
-- load("sutils")

-- This path should point to your HPCstack installation directory
local HPCstack="/opt/sw/other/apps/hpc-stack/"

-- Load HPC stack
prepend_path("MODULEPATH", pathJoin(HPCstack, "modulefiles/stack"))

-- load(pathJoin("cmake", os.getenv("cmake_ver") or "3.20.1"))
-- load(pathJoin("cmake", os.getenv("cmake_ver") or "3.22.1-6o"))

-- gnu_ver=os.getenv("gnu_ver") or "9.2.0"
-- load(pathJoin("gnu", gnu_ver))

-- prepend_path("MODULEPATH", "/scratch1/NCEPDEV/nems/role.epic/hpc-stack/libs/gnu-9.2/modulefiles/stack")

 load(pathJoin("hpc-stack", os.getenv("hpc_ver") or "1.2.0"))
-- load(pathJoin("hpc-gnu", os.getenv("hpc-gnu_ver") or "9.2"))
-- load(pathJoin("hpc-mpich", os.getenv("hpc-mpich_ver") or "3.3.2"))
-- load(pathJoin("hpc-mpich", os.getenv("hpc-mpich_ver") or "hpc-mpich"))
-- load("srw_common")
--
--
-- These are default modules from Hopper HPCstack installation directory
-- ----------------- /opt/sw/other/apps/hpc-stack/builds/modulefiles/mpi/gnu/10.3.0-ya/openmpi/4.1.2-4a ---------------------
--   fms/2021.03             mapl/2.7.3-esmf-8.3.0b09        nemsiogfs/2.5.3 (D)    upp/10.0.9   (D)
--   fms/2022.04 (D)         ncio/1.0.0               (D)    netcdf/4.7.4    (D)    wrf_io/1.2.0
--   hdf5/1.10.6 (D:ohpc)    nemsio/2.5.2             (D)    pio/2.5.3

-- -------------------------- /opt/sw/other/apps/hpc-stack/builds/modulefiles/compiler/gnu/10.3.0-ya ---------------------------
--   bacio/2.4.1  (D)    gfsio/1.4.1          (D)       ip2/1.1.2         (D)    netcdf/4.7.4           w3nco/2.4.1    (D)
--   bufr/11.5.0         gftl-shared/v1.3.0   (D)       jasper/2.0.25     (D)    prod_util/1.2.2        wgrib2/2.0.8   (D)
--   crtm/2.3.0   (D)    grib_util/1.2.2                jpeg/9.1.0               sfcio/1.4.1     (D)    yafyaml/v0.5.1 (D)
--   g2/3.4.2     (D)    hdf5/1.10.6          (ohpc)    landsfcutil/2.4.1 (D)    sigio/2.3.2     (D)    zlib/1.2.11    (D)
--   g2c/1.6.2           hpc-openmpi/4.1.2-4a           libpng/1.6.35     (D)    sp/2.3.3        (D)
--   g2tmpl/1.9.1 (D)    ip/3.3.3             (D)       nccmp/1.8.9.0     (D)    w3emc/2.9.2     (D)


load("jasper/2.0.25")
load("zlib/1.2.11")
load("libpng")

load("netcdf/4.7.4")
load("pio/2.5.3")
-- load("esmf/8.3.0b09")

load("fms/2022.04")

load("bufr/11.5.0")
load("bacio/2.4.1")
load("crtm/2.3.0")
load("g2/3.4.3")
load("g2tmpl/1.9.1")
load("ip/3.3.3")
load("sp/2.3.3")
load("w3emc/2.9.2")

load("gftl-shared/v1.3.0")
load("yafyaml/v0.5.1")
load("mapl/2.7.3-esmf-8.3.0b09")

load("nemsio/2.5.2")
load("sfcio/1.4.1")
load("sigio/2.3.2")
load("w3nco/2.4.1")
load("wrf_io/1.2.0")

load("ncio/1.0.0")
load("wgrib2/2.0.8")

load("nco")
load("nccmp")

-- load(pathJoin("nccmp", os.getenv("nccmp_ver") or "1.8.9"))
-- load(pathJoin("nco", os.getenv("nco_ver") or "4.9.3"))

setenv("CMAKE_C_COMPILER","mpicc")
setenv("CMAKE_CXX_COMPILER","mpicxx")
setenv("CMAKE_Fortran_COMPILER","mpif90")
setenv("CMAKE_Platform","hera.gnu")
