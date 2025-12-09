#!/bin/bash -l

module load python
module load PrgEnv-gnu
module unload cray-libsci
module unload cray-mpich
module unload cray-dsmml
module load cudatoolkit

export PRTE_MCA_ras_slurm_use_entire_allocation=1
export PRTE_MCA_ras_base_launch_orted_on_hn=1
module load cudatoolkit
#
# hack to workaround monkey business at NERSC
#
export PKG_CONFIG_PATH=/opt/cray/libfabric/1.22.0/lib64/pkgconfig:$PKG_CONFIG_PATH

cd $HOME/mtt_perlmutter
if [ $# -eq 0 ] ; then
  BRANCH=master
else
  BRANCH=$1
fi
if [ -f ./running_$BRANCH ] ; then
  exit
fi
#touch ./running_$BRANCH
SCRATCH_FILE=$BRANCH"_scratch"
SCRATCH_DIR=/global/homes/h/hpp/mtt_perlmutter/$SCRATCH_FILE
rm -f -r $SCRATCH_DIR/
mkdir $SCRATCH_DIR
export MTT_HOME=$PWD
export PRTE_MCA_prte_if_include=hsn0
echo "============== Testing $BRANCH  ==============="
pyclient/pymtt.py --verbose get_ompi_$BRANCH.ini
if [ $? -ne 0 ]
then
    echo "Something went wrong with fetch/build phase"
else
echo "============== Submitting batch job for Testing $BRANCH  ==============="
jobid=0
#jobid=`sbatch --wait --parsable -Am3169 -o slurm.$BRANCH.out -J mtt-$BRANCH -t 6:00:00 -N 1 -C cpu  -q regular ./run_mtt_backend.sh $BRANCH`
jobid=`sbatch --wait --parsable -Am3169_g -o slurm.$BRANCH.out -J mtt-$BRANCH -t 6:00:00 -N 1 -C gpu --gpus-per-node=4  -q regular ./run_mtt_backend.sh $BRANCH`
if [ $jobid -eq 1 ]; then
    echo "Something went wrong with batch job"
fi
fi
echo "============== Submitting test results for $BRANCH  ==============="
pyclient/pymtt.py --verbose  iu_reporter_$BRANCH.ini


