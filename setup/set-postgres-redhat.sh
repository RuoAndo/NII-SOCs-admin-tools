yum install -y postgresql-server
yum install -y python-psycopg2  
yum install -y emacs
service postgresql initdb
service postgresql start
echo "createdb sample"                                                                                  
sudo -u postgres createdb sample  
\cp -f postgres/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf
service postgresql restart
python postgres/pg_stat_database.py

yum install -y wget
yum install -y gcc g++

wget ftp://ftp.gnu.org/pub/gnu/global/global-6.5.5.tar.gz
tar zxvf global-6.5.5.tar.gz
yum install -y ncurses ncurses-devel ncurses-libs
cd global-6.5.5
./configure 
make 
make install

PATH=$PATH:/usr/local/bin
export PATH

cd ..

wget ftp://ftp.isc.org/isc/bind9/9.6.1-P1/bind-9.6.1-P1.tar.gz
tar zxvf bind-9.6.1-P1.tar.gz
\cp -f makelist.sh *py *pl *sh ./bind-9.6.1-P1/
#cp makelist.sh *py *pl *sh ./bind-9.6.1-P1/
#cp makelist.sh *py *pl *sh ./bind-9.6.1-P1/
#cp makelist.sh *py *pl *sh ./bind-9.6.1-P1/
cd bind-9.6.1-P1
./makelist.sh

curl -kL https://bootstrap.pypa.io/get-pip.py | python
pip install pymongo
pip install numpy
