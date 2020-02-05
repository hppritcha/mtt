#!/bin/bash -l

module load python/3.7-anaconda-2019.07

#
# somethings borked with Intel at the moment
#
if $( echo ${LOADEDMODULES} | grep --quiet 'PrgEnv-intel' ); then
    module swap PrgEnv-intel PrgEnv-gnu
fi

cd $HOME/mtt
if [ $# -eq 0 ] ; then
  BRANCH=master
  rm -f -r $HOME/mtt/master_scratch/*
else
  BRANCH=$1
  rm -f -r $HOME/mtt/v4.0.x_scratch/*
fi
export MTT_HOME=$PWD
echo "============== Testing $BRANCH  ==============="
pyclient/pymtt.py --verbose  get_ompi_$BRANCH.ini
if [ $? -ne 0 ]
then
    echo "Something went wrong with fetch/build phase"
    exit -1
fi
echo "============== Submitting batch job for Testing $BRANCH  ==============="
jobid=`sbatch --wait --parsable -N 4 -C knl --time=2:59:00 -qregular --tasks-per-node=32 ./run_mtt_backend.sh $BRANCH`
if [ $jobid -eq 1 ]; then
    echo "Something went wrong with batch job"
    exit -1
fi
pyclient/pymtt.py --verbose  iu_reporter_$BRANCH.ini

