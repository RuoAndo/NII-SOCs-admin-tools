import org.apache.spark.SparkContext
import scala.util.control.Breaks

import org.apache.spark.{SparkConf, SparkException}
import org.apache.spark.sql.hive.HiveContext

import org.apache.spark.sql.functions._

case class Dessert(timestamp:String, destIP:String, sourceIP:String, category:String) 

object Main {
  def main(args: Array[String]) {

      //val sc = new SparkContext("local[*]", "App") 
      val conf = new SparkConf()
      conf.set("spark.executor.memory", "32g")
      conf.set("spark.driver.memory", "32g")
      conf.set("spark.driver.maxResultSize", "32g")

      val sc = new SparkContext("local[*]", "App", conf)

      val sqlContext = new HiveContext(sc)

      import sqlContext.implicits._

      var start = System.currentTimeMillis
      val dessertRDD = sc.textFile("hdfs://192.168.76.216:9000/user/hadoop/" + args(0))

      val dessertDF = dessertRDD.map { record =>
      	  val splitRecord = record.split(",")
	  val timestamp = splitRecord(1)
	  val destIP = splitRecord(21)
	  val sourceIP = splitRecord(28)
	  val category = splitRecord(38)
	  Dessert(timestamp, destIP, sourceIP, category)
	  }.toDF

      // val numPerPriceRangeDF = dessertDF.groupBy("destIP").count().orderBy(desc("count")).show(5)
      val numPerPriceRangeDF = dessertDF.groupBy("category").count().orderBy("count").show(20)
      
      /*
      val top10 = dessertDF.take(10) 	  
      top10.foreach(println)
      */

      println("elapsed time: " + (System.currentTimeMillis - start) + " msec")

      sc.stop()
  }
}

