""" Defines an integration test for generate_FV3LAM_wflow script in the
ush directory """

#pylint: disable=invalid-name
import os
import sys
import unittest
from multiprocessing import Process

from python_utils import (
    cp_vrfy,
    run_command,
    define_macos_utilities,
    set_env_var,
    get_env_var,
)

from generate_FV3LAM_wflow import generate_FV3LAM_wflow

class Testing(unittest.TestCase):
    """ Class to run the tests. """
    def test_generate_FV3LAM_wflow(self):

        """ Test that a sample config can successfully
        lead to the creation of an experiment directory. No jobs are
        submitted. """

        # run workflows in separate process to avoid conflict between community and nco settings
        def run_workflow(USHdir, logfile):
            p = Process(target=generate_FV3LAM_wflow, args=(USHdir, logfile))
            p.start()
            p.join()
            exit_code = p.exitcode
            if exit_code != 0:
                sys.exit(exit_code)

        test_dir = os.path.dirname(os.path.abspath(__file__))
        USHdir = os.path.join(test_dir, "..", "..", "ush")
        logfile = "log.generate_FV3LAM_wflow"
        sed = get_env_var("SED")

        # community test case
        cp_vrfy(f"{USHdir}/config.community.yaml", f"{USHdir}/config.yaml")
        run_command(
            f"""{sed} -i 's/MACHINE: hera/MACHINE: linux/g' {USHdir}/config.yaml"""
        )
        run_workflow(USHdir, logfile)

    def setUp(self):
        define_macos_utilities()
        set_env_var("DEBUG", False)
        set_env_var("VERBOSE", False)
