<pre>
# spark-submit --master local[4] --driver-class-path=/root/elasticsearch-hadoop-5.5.0/dist/elasticsearch-hadoop-5.5.0.jar pyspark4.py
</pre>

# current Spark version requires Java8.

<pre>
Error: A JNI error has occurred, please check your installation and try again
Exception in thread "main" java.lang.NoClassDefFoundError: spark/TemplateEngine
</pre>

# installing Java.

<pre>
sudo apt-get install python-software-properties
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update

sudo apt-get install oracle-java8-installer
</pre>

# installing sbt.

<pre>
curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo
sudo yum install sbt
</pre>

# pyspark requierments.

hadoop-2.7
elasticsearch-hadoop-5.5.0
spark-2.1.1-bin-hadoop2.7

<pre>

# 1006* wget http://download.elastic.co/hadoop/elasticsearch-hadoop-5.5.0

# pyspark --master local[4] --driver-class-path=/root/elasticsearch-hadoop-5.5.0/                                                        
dist/        LICENSE.txt  NOTICE.txt   README.md    
[root@cn02040802 ~]# pyspark --master local[4] --driver-class-path=/root/elasticsearch-hadoop-5.5.0/dist/elasticsearch-hadoop-5.5.0.jar
Python 2.7.5 (default, Nov  6 2016, 00:28:07) 

[GCC 4.8.5 20150623 (Red Hat 4.8.5-11)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
17/07/10 15:29:47 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
17/07/10 15:29:51 WARN ObjectStore: Failed to get database global_temp, returning NoSuchObjectException
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /__ / .__/\_,_/_/ /_/\_\   version 2.1.1
      /_/

Using Python version 2.7.5 (default, Nov  6 2016 00:28:07)
SparkSession available as 'spark'.
>>> conf = {"es.nodes" : "127.0.0.1:9200", "es.resource" : "test-index/test"}
>>> rdd = sc.newAPIHadoopRDD("org.elasticsearch.hadoop.mr.EsInputFormat","org.apache.hadoop.io.NullWritable", "org.elasticsearch.hadoop.mr.LinkedMapWritable", conf=conf)
17/07/10 15:30:16 WARN EsInputFormat: Cannot determine task id...
17/07/10 15:30:17 WARN EsInputFormat: Cannot determine task id...
17/07/10 15:30:17 WARN EsInputFormat: Cannot determine task id...
17/07/10 15:30:17 WARN EsInputFormat: Cannot determine task id...
17/07/10 15:30:17 WARN EsInputFormat: Cannot determine task id...

>>> rdd.first()
17/07/10 15:34:15 WARN EsInputFormat: Cannot determine task id...
17/07/10 15:34:16 WARN EsInputFormat: Cannot determine task id...
17/07/10 15:34:16 WARN EsInputFormat: Cannot determine task id...
17/07/10 15:34:16 WARN EsInputFormat: Cannot determine task id...
17/07/10 15:34:16 WARN EsInputFormat: Cannot determine task id...
(u'1', {u'text': u'Elasticsearch RDD test', u'author': u'n', u'timestamp': u'2017-07-10T15:11:25.255219'})

</pre>