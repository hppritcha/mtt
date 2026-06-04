#!/bin/bash

module load rocm/6.4.3
module load python/3.11.5 

cd /usr/workspace/hpp/mtt
if [ $# -eq 0 ] ; then
  BRANCH=master
else
  BRANCH=$1
fi
if [ -f ./running_$BRANCH ] ; then
  exit
fi
#touch ./running_$BRANCH
SCRATCH_FILE=$BRANCH"_scratch"
SCRATCH_DIR=/usr/workspace/hpp/mtt/$SCRATCH_FILE
rm -f -r $SCRATCH_DIR/
mkdir $SCRATCH_DIR
export MTT_HOME=$PWD
echo "============== Testing $BRANCH  ==============="
pyclient/pymtt.py --verbose get_ompi_$BRANCH.ini
if [ $? -ne 0 ]
then
    echo "Something went wrong with fetch/build phase"
else
echo "============== Submitting batch job for Testing $BRANCH  ==============="
flux alloc -N 2  -o flux.$BRANCH.out --job mtt-$BRANCH ./run_mtt_backend.sh $BRANCH
fi
echo "============== Submitting test results for $BRANCH  ==============="
pyclient/pymtt.py --verbose  iu_reporter_$BRANCH.ini


