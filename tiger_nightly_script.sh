#!/bin/bash
#SBATCH -o nightly.o%j

the_date=`date`
echo $the_date >> ${HOME}/mtt/run_start_date
#rm -f -r /lus/scratch/n17276/mtt_tiger_short_tmp/*
rm -f -r /cray/css/users/n17276/mtt_tiger_short_tmp/*

export PERL_LWP_SSL_VERIFY_HOSTNAME=0

#pushd /cray/css/users/n17276/ompi-tests
#git pull origin master
#popd

cd /cray/css/users/n17276/mtt
module list
timeout 260m client/mtt --file ompi-tiger-nightly.ini --mpi-get --mpi-install --test-get --test-build --test-run  --verbose --force
sbatch --begin=02:10 -N 4 --ntasks=64  --exclusive --time=300:00 --job-name ompi-master /cray/css/users/n17276/mtt/tiger_nightly_script.sh

