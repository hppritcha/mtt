#!/bin/bash
#SBATCH -o nightly.o%j
sbatch -N 4 --ntasks=64  --exclusive --time=300:00 --job-name ompi-master /cray/css/users/n17276/mtt/tiger_nightly_script.sh
sbatch -N 4 --ntasks=64  --exclusive --time=180:00 --job-name ompi-v2.0.x /cray/css/users/n17276/mtt/tiger_nightly_v2.0.x_script.sh
sbatch -N 4 --ntasks=64  --exclusive --time=180:00 --job-name ompi-v2.x /cray/css/users/n17276/mtt/tiger_nightly_v2.x_script.sh

