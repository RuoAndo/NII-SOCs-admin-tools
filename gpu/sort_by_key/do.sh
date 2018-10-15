./make8.sh
./read1.sh
time ./gpu-cut-8 100000 100000 # fname nLines
time ./read1 tmp 100000 100000 # fname1 fname2 nLines
