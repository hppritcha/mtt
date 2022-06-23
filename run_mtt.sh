#!/bin/bash -l

module load python
module load PrgEnv-gnu
module unload cray-libsci
module unload cray-mpich
module unload cray-dsmml
module unload darshan
module load cudatoolkit


cd $HOME/mtt_perlmutter
if [ $# -eq 0 ] ; then
  BRANCH=master
else
  BRANCH=$1
fi
if [ -f ./running_$BRANCH ] ; then
  exit
fi
touch ./running_$BRANCH
SCRATCH_FILE=$BRANCH"_scratch"
SCRATCH_DIR=/global/homes/h/hpp/mtt_perlmutter/$SCRATCH_FILE
rm -f -r $SCRATCH_DIR
export MTT_HOME=$PWD
echo "============== Testing $BRANCH  ==============="
pyclient/pymtt.py  --verbose get_ompi_$BRANCH.ini
rm ./running_$BRANCH

