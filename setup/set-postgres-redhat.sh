yum install -y postgresql-server
yum install -y python-psycopg2  
yum install -y emacs
service postgresql initdb
service postgresql start
echo "createdb sample"                                                                                  
sudo -u postgres createdb sample  
\cp -f pg_hba.conf /var/lib/pgsql/data/pg_hba.conf
service postgresql restart
python pg_stat_database.py

