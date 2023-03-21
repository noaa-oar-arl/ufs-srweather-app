help([[
This module loads python environment for running the UFS SRW App on
the GMU machine Hopper
]])

whatis([===[Loads libraries needed for running the UFS SRW App on Hopper ]===])

load("rocoto")
load("miniconda3")

-- prepend_path("MODULEPATH","/scratch1/NCEPDEV/nems/role.epic/miniconda3/modulefiles")
-- load(pathJoin("miniconda3", os.getenv("miniconda3_ver") or "4.12.0"))

if mode() == "load" then
   LmodMsgRaw([===[Please do the following to create environment and activate conda:
       > conda env create -f environment_hopper_wflow.yml
       > conda activate regional_workflow
]===])
end
