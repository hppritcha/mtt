#!/bin/bash
#SBATCH -o libfabric.o%j

cd /cray/css/users/n17276/mtt
timeout 170m client/mtt --file ompi-libfabric.ini --mpi-get --mpi-install --test-get --test-build --test-run --force
#sbatch --begin=23:10 -N 4 --ntasks=64  --exclusive --time=180:00 --job-name ompi-master /cray/css/users/n17276/mtt/tiger_nightly_script.sh

