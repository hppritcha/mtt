#!/bin/bash -l

module load python
module load PrgEnv-gnu
#
# somethings borked with Intel at the moment
#
if [ $# -eq 0 ] ; then
  BRANCH=master
else
  BRANCH=$1
fi
cd $HOME/mtt_branch
export MTT_HOME=$PWD
pyclient/pymtt.py --verbose run_ibm_tests_mpirun_$BRANCH.ini

