#!/bin/bash -l

module load python-3.7.7-gcc-4.8.5-hw4wxvz           
module load gcc-9.1.0-gcc-4.8.5-nhd4fe4     
module load py-pyyaml-5.3.1-gcc-4.8.5-vl67ise
module load py-setuptools-46.1.3-gcc-4.8.5-styz44m   
module load py-pip-19.3-gcc-4.8.5-zifcadu

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
cd $HOME/mtt
export MTT_HOME=$PWD
pyclient/pymtt.py --verbose run_ibm_tests_mpirun_$BRANCH.ini

