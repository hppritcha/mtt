#!/bin/bash
#SBATCH -o v2.x.o%j

export PERL_LWP_SSL_VERIFY_HOSTNAME=0

the_date=`date`
echo $the_date >> ${HOME}/mtt/run_v3.x_start_date
rm -f -r /lus/scratch/n17276/mtt_tiger_short_v3.x_tmp

module load gcc/6.3.0

timeout 170m client/mtt --file ompi-tiger-nightly-v3.x.ini --mpi-get --mpi-install --test-get --test-build --test-run --force

#sbatch --begin=21:10 -N 4 --ntasks=64  --exclusive --time=560:00 --job-name ompi-v3.x /cray/css/users/n17276/mtt/tiger_nightly_v2.x_script.sh

