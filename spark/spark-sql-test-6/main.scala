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

      
      val dessertRDD = sc.textFile("hdfs://192.168.76.216:9000/user/hadoop/" + "sinet_egress_all_20201228")

      val dessertDF = dessertRDD.map { record =>
      	  val splitRecord = record.split(",")
	  val timestamp = splitRecord(1).drop(1).dropRight(1)
	  val destIP = splitRecord(21).drop(1).dropRight(1)
	  val sourceIP = splitRecord(28).drop(1).dropRight(1)
	  val category = splitRecord(36).drop(1).dropRight(1)
	  Dessert(timestamp, destIP, sourceIP, category)
	  }.toDF

      // val top10 = dessertDF.take(10) 	  
      // top10.foreach(println)

      println("---")
      // val name_price_2 = dessertDF.where($"destIP" === "204.11.56.48").take(10)
      val name_price_2 = dessertDF.where($"category" === "abused-drugs") //.take()
      // val name_price_2 = dessertDF.where($"category" === "phishing").take(100)

      name_price_2.foreach { row => 
            		    println(row)
		    	    }

      // println("COUNT: " + name_price_2.size) 
      // name_price_2.foreach(println)

      // println(name_price_2)
      
      /*
      numPerPriceRangeDF.foreach { row => println(row(0)) }

      numPerPriceRangeDF.foreach { row =>
				 val wordRDD = dessertRDD.filter(word => word.matches(".*" + row(0) + ".*"))
     				 val wordArray = wordRDD.collect 
      				 wordArray.foreach(println)
				 }
      */


      /*
      val top10 = dessertDF.take(10) 	  
      top10.foreach(println)
      */

      println("elapsed time: " + (System.currentTimeMillis - start) + " msec")

      sc.stop()
  }
}

