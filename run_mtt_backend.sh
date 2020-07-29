#!/bin/bash -l

module load miniconda-3/latest
module swap PrgEnv-intel PrgEnv-gnu
module swap craype-mic-knl craype-haswell
if [ $# -eq 0 ] ; then
  BRANCH=master
else
  BRANCH=$1
fi
cd $HOME/mtt
export MTT_HOME=$PWD
pyclient/pymtt.py --verbose run_ibm_tests_alps_$BRANCH.ini

