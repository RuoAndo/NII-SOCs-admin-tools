rm -rf *png

./test.sh 0 covid19.txt
./test.sh 0 hc.txt
./test.sh 0 gs.txt

./test.sh 500 covid19.txt
./test.sh 500 hc.txt
./test.sh 500 gs.txt

./test.sh 1000 covid19.txt
./test.sh 1000 hc.txt
./test.sh 1000 gs.txt
