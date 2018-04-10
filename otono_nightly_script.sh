#!/bin/bash

rm -f -r ~/mtt_nightly_scratch/*

cd /home/hpp/mtt
the_date=`date`
echo $the_date >> ${HOME}/mtt/run_start_date_nightly
#PERL5LIB="/home/hpp/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
#PERL_LOCAL_LIB_ROOT="/home/hpp/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
#PERL_MB_OPT="--install_base \"/home/hpp/perl5\""; export PERL_MB_OPT;
#PERL_MM_OPT="INSTALL_BASE=/home/hpp/perl5"; export PERL_MM_OPT;

timeout 260m client/mtt --file ompi-otono-nightly.ini --mpi-get --mpi-install --test-get --test-build --test-run  --verbose --force
#cp mtt-nightly-logfile.txt mtt-nightly-logfile.$the_date

