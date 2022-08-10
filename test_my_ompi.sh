#!/bin/bash -l

#module load python/3.7-anaconda-2019.07
module load PrgEnv-gnu
module unload cray-libsci
module unload cray-mpich
module unload cray-dsmml

export PATH=/ccs/home/howardp/ompi/install/bin:$PATH
#export OMPI_MCA_pml=cm
export FI_PROVIDER=cxi
export PRTE_MCA_plm=ssh
export OMPI_MCA_btl=self,sm,ofi
export PRTE_MCA_plm_ssh_pass_libpath=/opt/cray/pe/gcc/11.2.0/snos/lib/../lib64
export PRTE_MCA_prte_if_include=hsn0
export OMPI_MCA_smsc=cma

cd $HOME/mtt
#. $HOME/prep_libfab.sh
echo "=========================MODULESS================"
module list
echo "=========================USING THIS MPICC================"
which mpicc
rm -f -r test_scratch/*
export MTT_HOME=$PWD
pyclient/pymtt.py --verbose  test_my_ompi.ini
grep FAIL test_scratch/mttresults.txt
grep OUT test_scratch/mttresults.txt

