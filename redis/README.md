
<pre>
 1998  wget http://download.redis.io/releases/redis-4.0.2.tar.gz
 1999  tar zxvf redis-4.0.2.tar.gz 
 2000  cd redis-4.0.2/
 2002  ./configure
 2003  time make
 2004  time make install
</pre>

<pre>
127.0.0.1:6379> set key value
OK
127.0.0.1:6379> get key
"value"
</pre>