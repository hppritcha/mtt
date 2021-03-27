#!/bin/bash -l

module load gcc
#
# somethings borked with Intel at the moment
#
#if $( echo ${LOADEDMODULES} | grep --quiet 'PrgEnv-intel' ); then
#    module swap PrgEnv-intel PrgEnv-gnu
#fi

if [ $# -eq 0 ] ; then
  BRANCH=master
else
  BRANCH=$1
fi
cd /usr/projects/artab/users/hpp/mtt
export MTT_HOME=$PWD
pyclient/pymtt.py --verbose run_ibm_tests_mpirun_$BRANCH.ini

