from pyspark import SparkContext, SparkConf
from pyspark.sql import SQLContext

conf = {"es.nodes" : "127.0.0.1:9200", "es.resource" : "test-index/test"}
#sc = SparkContext("127.0.0.1:9200", "test-index/test")
sc = SparkContext("local", "simple app")

rdd = sc.newAPIHadoopRDD("org.elasticsearch.hadoop.mr.EsInputFormat","org.apache.hadoop.io.NullWritable", "org.elasticsearch.hadoop.mr.LinkedMapWritable", conf=conf)

rdd.first()

print rdd.first()
print "test"

