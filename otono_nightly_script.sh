rm -f -r ~/mtt_nightly_scratch/*

cd /home/hpp/mtt
timeout 260m client/mtt --file ompi-otono-nightly.ini --mpi-get --mpi-install --test-get --test-build --test-run  --verbose

