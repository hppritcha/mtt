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
else
  BRANCH=$1
fi
SCRATCH_FILE=$BRANCH"_scratch"
SCRATCH_DIR=/global/homes/h/hpp/mtt/$SCRATCH_FILE
rm -f -r $SCRATCH_DIR
export MTT_HOME=$PWD
echo "============== Testing $BRANCH  ==============="
pyclient/pymtt.py --verbose  get_ompi_$BRANCH.ini
if [ $? -ne 0 ]
then
    echo "Something went wrong with fetch/build phase"
else
    echo "============== Submitting batch job for Testing $BRANCH  ==============="
    jobid=`sbatch -o slurm.$BRANCH.out --wait --parsable -N 4 -C knl --time=8:00:00 -qregular --tasks-per-node=32 -J $BRANCH ./run_mtt_backend.sh $BRANCH`
    if [ $jobid -eq 1 ]; then
        echo "Something went wrong with batch job"
    fi
fi
pyclient/pymtt.py --verbose  iu_reporter_$BRANCH.ini

