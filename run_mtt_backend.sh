#!/bin/bash -l


module load rocm/6.4.3
module load python/3.11.5 

if [ $# -eq 0 ] ; then
  BRANCH=master
else
  BRANCH=$1
fi
cd /usr/WS1/hpp/mtt
export MTT_HOME=$PWD
pyclient/pymtt.py --verbose run_ibm_tests_mpirun_$BRANCH.ini

