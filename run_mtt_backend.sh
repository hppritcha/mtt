#!/usr/bin/bash -l
#PBS -l select=2:ncpus=32:mpiprocs=32:system=polaris
#PBS -l place=scatter
#PBS -l walltime=1:00:00
#PBS -o pbs.out
#PBS -e pbs.err
#PBS -q debug
#PBS -A CSC250STPR27

echo "Hello there"

module load PrgEnv-gnu
module use --append $HOME/spack/share/spack/modules/cray-sles15-zen3
module load python-3.9.13-gcc-11.2.0-xn5ccoy

cd $HOME/mtt

if [ $# -eq 0 ] ; then
  BRANCH=master
else
  BRANCH=$1
fi
if [[ "$BRANCH" = "master" || "$BRANCH" = "v5.0.x" ]]; then
  LAUNCHER=mpirun
else
  LAUNCHER=alps
fi
cd $HOME/mtt
export MTT_HOME=$PWD
echo "LAUNCHER = ",$LAUNCHER
echo "BRANCH = ",$BRANCH
pyclient/pymtt.py --verbose run_ibm_tests_$LAUNCHER\_$BRANCH.ini

