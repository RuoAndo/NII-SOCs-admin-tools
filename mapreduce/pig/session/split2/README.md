# installing EPEL and numpy.

<pre>
# wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# rpm -ivh epel-release-latest-7.noarch.rpm

# yum install python-pip 
# pip install numpy
</pre>

# do.

<pre>
./do.sh list
./cat.sh
./init.sh
./repeat.sh
</pre>

<pre>
time ./do.sh list
</pre>

# cluster checking

<pre>
python 5.py r 2 | tee tmp
time ./head2.sh tmp r | tee tmp2
</pre>