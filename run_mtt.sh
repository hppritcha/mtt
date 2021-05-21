#!/bin/bash -l

module load python/3.6-anaconda-5.0.1

#
# somethings borked with Intel at the moment
#
#if $( echo ${LOADEDMODULES} | grep --quiet 'PrgEnv-intel' ); then
#    module swap PrgEnv-intel PrgEnv-gnu
#fi

cd $HOME/mtt
if [ $# -eq 0 ] ; then
  BRANCH=master
else
  BRANCH=$1
fi
SCRATCH_FILE=$BRANCH"_scratch"
SCRATCH_DIR=/lustre/ttscratch1/hpp/mtt/$SCRATCH_FILE
rm -f -r $SCRATCH_DIR
export MTT_HOME=$PWD
echo "============== Testing $BRANCH  ==============="
pyclient/pymtt.py --verbose  get_ompi_$BRANCH.ini
if [ $? -ne 0 ]
then
    echo "Something went wrong with fetch/build phase"
    exit -1
fi
echo "============== Submitting batch job for Testing $BRANCH  ==============="
jobid=`sbatch -o slurm.$BRANCH.out --wait --parsable -N 4 -p knl -Alanl-dev --time=6:00:00 --tasks-per-node=8 ./run_mtt_backend.sh $BRANCH`
if [ $jobid -eq 1 ]; then
    echo "Something went wrong with batch job"
    exit -1
fi
pyclient/pymtt.py --verbose  iu_reporter_$BRANCH.ini

