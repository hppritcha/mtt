#!/bin/bash -l

#module use --append /soft/packaging/spack/gnu-ldpath/modules/linux-sles15-x86_64 
#module load libevent
#module load hwloc

python -m venv $HOME/mtt_env
source $HOME/mtt_env/bin/activate

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
    rm -f ompi.$BRANCH.stderr
    rm -f ompi.$BRANCH.stdout
    qsub -Wblock=true -l select=2:ncpus=32:mpiprocs=32,filesystems=home -lwalltime=1:00:00 -e ompi.$BRANCH.stderr -o ompi.$BRANCH.stdout -q debug -A OMPI-xpostECP -- $PWD/run_mtt_backend.sh $BRANCH
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

