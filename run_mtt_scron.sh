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
sbatch -Am3169_g -o slurm.$BRANCH.out -J mtt-$BRANCH -t 2:00:00 -N 4 -C gpu  --gpus-per-node=1 ./run_mtt.sh $BRANCH
#sbatch -Am3169_g -J mtt-$BRANCH -t 2:00:00 -N 1 -C gpu  --gpus-per-node=1 ./run_mtt.sh $BRANCH
