import sys
argvs = sys.argv 
argc = len(argvs)

from pyspark.sql import SQLContext
from pyspark.sql import Row
from pyspark import SparkContext

sc = SparkContext("local", "CSV test")
sqlContext = SQLContext(sc)

whole_log_df_2 = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").load(argvs[1])
print whole_log_df_2.printSchema()
print whole_log_df_2.show(5)

whole_log_df_3 = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load(argvs[1])
print whole_log_df_3.printSchema()
