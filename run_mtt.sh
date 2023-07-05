#!/bin/bash -l

#module load python/3.7-anaconda-2019.07
module load PrgEnv-gnu
module unload cray-libsci
module unload cray-mpich
module unload cray-dsmml
module load rocm

export PRTE_MCA_ras_slurm_use_entire_allocation=1
export PRTE_MCA_ras_base_launch_orted_on_hn=1
module load libtool

env
sleep 60
cd $HOME/mtt
if [ $# -eq 0 ] ; then
  #
  # workaround for OMPI issue 10153
  #
  export PRTE_MCA_plm=ssh
  BRANCH=master
else
  BRANCH=$1
fi
SCRATCH_FILE=$BRANCH"_scratch"
SCRATCH_DIR=/ccs/home/howardp/mtt/$SCRATCH_FILE
rm -f -r $SCRATCH_DIR
export MTT_HOME=$PWD
echo "============== Testing $BRANCH  ==============="
pyclient/pymtt.py --verbose  get_ompi_$BRANCH.ini
echo $?
if [ $? -ne 0 ]
then
    echo "Something went wrong with fetch/build phase"
else
    rm slurm.$BRANCH.out
    echo "============== Submitting batch job for Testing $BRANCH  ==============="
    jobid=`sbatch -o slurm.$BRANCH.out --wait --parsable -N 4  -N 4 -AGEN010_crusher -t 8:00:00 --tasks-per-node=32 -J $BRANCH ./run_mtt_backend.sh $BRANCH`
    if [ $jobid -eq 1 ]; then
        echo "Something went wrong with batch job"
    fi
fi
pyclient/pymtt.py --verbose  iu_reporter_$BRANCH.ini

