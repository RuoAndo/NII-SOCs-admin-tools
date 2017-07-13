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

<pre>
12541   2017-07-13 10:25:28  python 5.py r 2 | tee tmp
12546   2017-07-13 10:29:21  time ./head2.sh tmp r | tee tmp2
</pre>