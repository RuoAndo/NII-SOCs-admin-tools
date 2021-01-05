import org.apache.spark.SparkContext
import scala.util.control.Breaks

import org.apache.spark.{SparkConf, SparkException}
import org.apache.spark.sql.hive.HiveContext

import org.apache.spark.sql.functions._
// import java.io.PrintWriter

case class Dessert(timestamp:String, destIP:String, destPort:String, sourceIP:String, category:String, application:String) 

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

      println("arg: " + args(0))
      
      val dessertRDD = sc.textFile("hdfs://192.168.76.216:9000/user/hadoop/" + args(0))

      val dessertDF = dessertRDD.map { record =>
      	  val splitRecord = record.split(",")
	  val timestamp = splitRecord(0).drop(1).dropRight(1)
	  val destPort = splitRecord(19).drop(1).dropRight(1)
	  val destIP = splitRecord(20).drop(1).dropRight(1)
	  val sourceIP = splitRecord(27).drop(1).dropRight(1)
	  val category = splitRecord(35).drop(1).dropRight(1)
	  val application = splitRecord(37).drop(1).dropRight(1)
	  Dessert(timestamp, destIP, destPort, sourceIP, category, application)
	  }.toDF

      // val top10 = dessertDF.take(10) 	  
      // top10.foreach(println)

      println("---")
      // val name_price_2 = dessertDF.where($"destIP" === "204.11.56.48").take(10)
      val name_price_2 = dessertDF.where($"category" === "abused-drugs") //.take()
      //val name_price_2 = dessertDF.where($"destPort" === "443") //.take()
      // val name_price_2 = dessertDF.where($"application" === "malware")// .take(10)


      /*
      import java.io.{ FileOutputStream=>FileStream, OutputStreamWriter=>StreamWriter };
      val fileName = "test.txt"
      val encode = "UTF-8"
      val append = true

      val fileOutPutStream = new FileStream(fileName, append)
      val writer = new StreamWriter( fileOutPutStream, encode )
      */
      
      name_price_2.foreach { row => 
            		    // writer.write(row + "\n")
			    println(row)
		    	    }

      // writer.close

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

