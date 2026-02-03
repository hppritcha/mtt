#!/bin/bash -l
#
# scron script to submit the backend run_mtt.sh script on perlmutter compute nodes
#

cd $HOME/mtt_perlmutter
if [ $# -eq 0 ] ; then
  BRANCH=master
else
  BRANCH=$1
fi
./run_mtt.sh v6.0.x
./run_mtt.sh v5.0.x
./run_mtt.sh master
#dep_id=`sbatch --parsable -Am3169 -o slurm.master.out -J mtt-master -N 1 -C cpu -t 4:00:00  -q regular ./run_mtt.sh master`
#sbatch -d afterok:$dep_id -Am3169 -o slurm.v5.0.x.out -J mtt-v5.0.x -t 6:00:00 -N 4 -C cpu  -q regular ./run_mtt.sh v5.0.x
#dep_id=`sbatch --parsable -Am1759 -o slurm.master.out -J mtt-master -t 6:00:00 -N 4 -C cpu  -q regular ./run_mtt.sh master`
#sbatch -d afterok:$dep_id -Am1759_g -o slurm.v5.0.x.out -J mtt-v5.0.x -t 6:00:00 -N 4 -C cpu  -q regular ./run_mtt.sh v5.0.x
#sbatch -Am3169_g -J mtt-$BRANCH -t 2:00:00 -N 1 -C gpu  --gpus-per-node=1 ./run_mtt.sh $BRANCH
