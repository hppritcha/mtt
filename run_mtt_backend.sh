#!/bin/bash -l

#module load python/3.7-anaconda-2019.07
#
# somethings borked with Intel at the moment
#
module load PrgEnv-gnu
module unload cray-libsci
module unload cray-mpich
module unload cray-dsmml
module load rocm

export PRTE_MCA_ras_slurm_use_entire_allocation=1
export PRTE_MCA_ras_base_launch_orted_on_hn=1
export PRTE_MCA_plm=slurm

module list

if [ $# -eq 0 ] ; then
  BRANCH=master
else
  BRANCH=$1
fi
cd $HOME/mtt
export MTT_HOME=$PWD
echo "##########################################"
which mpirun
echo "##########################################"
pyclient/pymtt.py --verbose run_ibm_tests_mpirun_$BRANCH.ini

