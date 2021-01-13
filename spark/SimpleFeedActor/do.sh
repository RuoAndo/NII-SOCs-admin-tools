sbt clean package; ${SPARK_HOME}/bin/spark-submit --master local[*] --class StreamingFirst target/scala-2.12/app_2.12-1.4.6.jar localhost 9999
