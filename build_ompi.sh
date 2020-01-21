#!/bin/bash -l

module swap PrgEnv-intel PrgEnv-gnu
cd $HOME/mtt
rm -f -r master_scratch/*
export MTT_HOME=$PWD
pyclient/pymtt.py --verbose get_ompi_master.ini
#qsub -n 128 -t 160 -A CSC250STPR27 ./run_imb.sh $BRANCH
#qsub -n 8 --jobname ompi.$BRANCH -q debug-flat-quad -t 60 -A CSC250STPR27 ./run_imb.sh $BRANCH
#
# we'll need something to wait here
#
