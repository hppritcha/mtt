#!/bin/bash -l

module load python
module load PrgEnv-gnu
module unload cray-libsci
module unload cray-mpich
module unload cray-dsmml
module load cudatoolkit

export PRTE_MCA_ras_slurm_use_entire_allocation=1
export PRTE_MCA_ras_base_launch_orted_on_hn=1
module load cudatoolkit

if [ $# -eq 0 ] ; then
  BRANCH=master
else
  BRANCH=$1
fi
cd $HOME/mtt_perlmutter
export MTT_HOME=$PWD
pyclient/pymtt.py --verbose run_ibm_tests_mpirun_$BRANCH.ini

