#!/bin/bash
#SBATCH -o oshmem.o%j

the_date=`date`
echo $the_date >> ${HOME}/mtt/run_v2.x_start_date
rm -f -r /lus/scratch/n17276/mtt_tiger_short_v2.x_tmp

cd /cray/css/users/n17276/mtt
timeout 170m client/mtt --file oshmem.ini --mpi-get --mpi-install --test-get --test-build --test-run
#sbatch --begin=3:10 -N 4 --ntasks=64  --exclusive --time=180:00 --job-name ompi-v2.x /cray/css/users/n17276/mtt/tiger_nightly_v2.x_script.sh

