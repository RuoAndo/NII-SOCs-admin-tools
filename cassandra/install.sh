yum install -y jna
yum install -y java-1.7.0*
cp datasax.repo /etc/yum.repos.d/
yum -y install cassandra20
curl -kL https://bootstrap.pypa.io/get-pip.py | python
pip install cassandra-driver
cp cassandra.yaml /etc/cassandra/conf/cassandra.yaml
/etc/init.d/cassandra restart
