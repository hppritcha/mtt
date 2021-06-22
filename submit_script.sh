#!/bin/bash -l

module load cgpu
cd $HOME/mtt_cgpu
sbatch -o slurm.master.out -J mtt_cgpu_master -C gpu -t 60 -G 1 --ntasks-per-node=4 -c 4 -Am3169 ./run_mtt.sh
