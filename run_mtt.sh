#!/bin/bash -l

# these not needed after upgrade to RHEL 8
#module load python-3.7.7-gcc-4.8.5-hw4wxvz           
#module load gcc-9.1.0-gcc-4.8.5-nhd4fe4     
#module load py-pyyaml-5.3.1-gcc-4.8.5-vl67ise
#module load py-setuptools-46.1.3-gcc-4.8.5-styz44m   
#module load py-pip-19.3-gcc-4.8.5-zifcadu

#
# default /tmp on stretch is borked
#
#export TMPDIR=$HOME/mtt_tmpdir

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
SCRATCH_DIR=/users/hpritchard/mtt/$SCRATCH_FILE
rmdir --ignore-fail-on-non-empty $SCRATCH_DIR
mkdir $SCRATCH_DIR
export MTT_HOME=$PWD
echo "============== Testing $BRANCH  ==============="
pyclient/pymtt.py --verbose  get_ompi_$BRANCH.ini
if [ $? -ne 0 ]
then
    echo "Something went wrong with fetch/build phase"
else
echo "============== Submitting batch job for Testing $BRANCH  ==============="
jobid=`sbatch -o slurm.$BRANCH.out --exclude=st35 --wait --parsable -N 4 --time=6:00:00 --tasks-per-node=8 ./run_mtt_backend.sh $BRANCH`
if [ $jobid -eq 1 ]; then
    echo "Something went wrong with batch job"
fi
fi
pyclient/pymtt.py --verbose  iu_reporter_$BRANCH.ini

