#!/bin/bash
#SBATCH -o test_build.o%j

rm -f -r /cray/css/users/n17276/mtt_tiger_short_tmp/*

export PERL_LWP_SSL_VERIFY_HOSTNAME=0

cd /cray/css/users/n17276/mtt
module list
timeout 260m client/mtt --file ompi-tiger-nightly.ini --mpi-get --mpi-install --no-reporter  --debug --force
#sbatch --begin=02:10 -N 4 --ntasks=64  --exclusive --time=300:00 --job-name ompi-master /cray/css/users/n17276/mtt/tiger_nightly_script.sh

