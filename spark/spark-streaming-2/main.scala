import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.storage.StorageLevel
import org.apache.log4j.{Level, Logger}

object StreamingFirst {
  def main(args: Array[String]) {
    Logger.getRootLogger.setLevel(Level.WARN)

    val sparkConf = new SparkConf().setAppName("StreamingFirst")
    val sc = new SparkContext(sparkConf)
    val ssc = new StreamingContext(sc, Seconds(10))
    val lines = ssc.socketTextStream(args(0),
                                     args(1).toInt,
                                     StorageLevel.MEMORY_AND_DISK_SER)
    val words = lines.flatMap(_.split(",")).filter(_.nonEmpty)
    val wordCounts = words.map((_, 1)).reduceByKey(_ + _)
    wordCounts.print()
    ssc.start()
    ssc.awaitTermination()

  }
}
