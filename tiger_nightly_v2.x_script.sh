#!/bin/bash
#SBATCH -o v2.x.o%j

export PERL_LWP_SSL_VERIFY_HOSTNAME=0

cd /cray/css/users/n17276/mtt
export TMPDIR=/tmp

the_date=`date`
echo $the_date >> ${HOME}/mtt/run_v3.1.x_start_date
rm -f -r /cray/css/users/n17276/mtt_tiger_short_v3.1.x_tmp
timeout 170m client/mtt --file ompi-tiger-nightly-v3.1.x.ini --mpi-get --mpi-install --test-get --test-build --test-run --verbose --force

the_date=`date`
echo $the_date >> ${HOME}/mtt/run_v3.0.x_start_date
rm -f -r /cray/css/users/n17276/mtt_tiger_short_v3.0.x_tmp
timeout 170m client/mtt --file ompi-tiger-nightly-v3.0.x.ini --mpi-get --mpi-install --test-get --test-build --test-run --verbose --force

the_date=`date`
echo $the_date >> ${HOME}/mtt/run_v2.x_start_date
rm -f -r /cray/css/users/n17276/mtt_tiger_short_v2.x_tmp
timeout 170m client/mtt --file ompi-tiger-nightly-v2.x.ini --mpi-get --mpi-install --test-get --test-build --test-run --verbose --force

#the_date=`date`
#echo $the_date >> ${HOME}/mtt/run_v2.0.x_start_date
#rm -f -r /lus/scratch/n17276/mtt_tiger_short_v2.0.x_tmp
#rm -f -r /cray/css/users/n17276/mtt_tiger_short_v2.0.x_tmp
#timeout 170m client/mtt --file ompi-tiger-nightly-v2.0.x.ini --mpi-get --mpi-install --test-get --test-build --test-run --verbose --force


sbatch --begin=21:10 -N 4 --ntasks=64  --exclusive --time=560:00 --job-name ompi-v2.x.x /cray/css/users/n17276/mtt/tiger_nightly_v2.x_script.sh

