#!/bin/bash -l

module load miniconda-3/latest
module swap craype-mic-knl craype-haswell

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
SCRATCH_DIR=/home/howardp/mtt/$SCRATCH_FILE
rm -f -r $SCRATCH_DIR

export MTT_HOME=$PWD
echo "============== Testing $BRANCH  ==============="
pyclient/pymtt.py --verbose  get_ompi_$BRANCH.ini
if [ $? -ne 0 ]
then
    echo "Something went wrong with fetch/build phase"
    exit -1
fi
#qsub -n 128 -t 160 -A CSC250STPR27 ./run_imb.sh $BRANCH
jobid=`qsub -n 8 --jobname ompi.$BRANCH -q debug-flat-quad -t 60 -A CSC250STPR27 ./run_mtt_backend.sh $BRANCH`
export QSTAT_HEADER="State"
nlines=`qstat $jobid | wc -l`
while [ $nlines != 0 ]
do
sleep 120
nlines=`qstat $jobid | wc -l`
done
pyclient/pymtt.py --verbose  iu_reporter_$BRANCH.ini

