#!/bin/bash -l

module load python

cd $HOME/mtt_perlmutter
if [ $# -eq 0 ] ; then
  BRANCH=master
else
  BRANCH=$1
fi
SCRATCH_FILE=$BRANCH"_scratch"
SCRATCH_DIR=/global/homes/h/hpp/mtt_perlmutter/$SCRATCH_FILE
rm -f -r $SCRATCH_DIR
export MTT_HOME=$PWD
echo "============== Testing $BRANCH  ==============="
pyclient/pymtt.py --verbose  get_ompi_$BRANCH.ini

