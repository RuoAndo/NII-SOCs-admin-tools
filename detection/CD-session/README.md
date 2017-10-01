<pre>
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm 
yum install epel-release
yum install python-pip

pip install pandas
pip install numpy
pip install keras
pip install sklearn
yum install -y python-devel
pip install matplotlib
yum install -y python34-tkinter
pip install tensorflow
</pre>

<pre>
time ./auto.sh instIDlist 
time ./do-gendata.sh list instIDlist  
</pre>