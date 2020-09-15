#!/bin/bash -l

module load miniconda-3/latest
module swap PrgEnv-intel PrgEnv-gnu
module swap craype-mic-knl craype-haswell
if [ $# -eq 0 ] ; then
  BRANCH=master
else
  BRANCH=$1
fi
if [ $BRANCH = "master" ]; then
  LAUNCHER=mpirun
else
  LAUNCHER=alps
fi
cd $HOME/mtt
export MTT_HOME=$PWD
echo "LAUNCHER = ",$LAUNCHER
echo "BRANCH = ",$BRANCH
pyclient/pymtt.py --verbose run_ibm_tests_$LAUNCHER\_$BRANCH.ini

