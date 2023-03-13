#!/bin/bash -l

module load PrgEnv-gnu
module use --append $HOME/spack/share/spack/modules/cray-sles15-zen3
module load python-3.9.13-gcc-11.2.0-xn5ccoy


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
    pyclient/pymtt.py --verbose  iu_reporter_$BRANCH.ini
else
    rm ompi.$BRANCH.stderr
    rm ompi.$BRANCH.stdout
    qsub -Wblock=true -l select=2:ncpus=32:mpiprocs=32:system=polaris -l place=scatter -l filesystems=grand:home -l walltime=1:00:00 -e ompi.$BRANCH.stderr -o ompi.$BRANCH.stdout -q debug -A CSC250STPR27 -- $PWD/run_mtt_backend.sh $BRANCH
#   jobid=`qsub -Wblock=true --jobname ompi.$BRANCH -e ompi.$BRANCH.stderr -o ompi.$BRANCH.stdout ./run_mtt_backend.sh $BRANCH`
#   export QSTAT_HEADER="State"
#   nlines=`qstat $jobid | wc -l`
#   while [ $nlines != 0 ]
#   do
#       sleep 120
#       nlines=`qstat $jobid | wc -l`
#   done
fi
pyclient/pymtt.py --verbose  iu_reporter_$BRANCH.ini

