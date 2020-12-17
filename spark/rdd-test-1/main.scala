import org.apache.spark.SparkContext
import scala.util.control.Breaks

import org.apache.spark.{SparkConf, SparkException}

object Main {
  def main(args: Array[String]) {

      //val sc = new SparkContext("local[*]", "App") 

      val conf = new SparkConf()
      conf.set("spark.executor.memory", "32g")
      conf.set("spark.driver.memory", "32g")
      conf.set("spark.driver.maxResultSize", "32g")

      val sc = new SparkContext("local[*]", "App", conf)

      var start = System.currentTimeMillis
      val rddFromFile = sc.textFile("hdfs://192.168.76.216:9000/user/hadoop/ingress-CN-all")
 
      val rdd = rddFromFile.map(f=>{
      	  f.split(",")
      })
      println("elapsed time: " + (System.currentTimeMillis - start) + " msec")

      start = System.currentTimeMillis
      val wordAndOnePairRDD = rdd.map(word => (word(1),1))
      val wordAndOnePairArray = wordAndOnePairRDD.collect

      val top3 = wordAndOnePairArray.take(3)
      top3.foreach(println)
      
      val wordAndCountRDD = wordAndOnePairRDD.reduceByKey((result,enum) => result + enum)
      val wordAndCountArray = wordAndCountRDD.collect
      println("elapsed time: " + (System.currentTimeMillis - start) + " msec")

      val top3_2 = wordAndCountArray.take(3)
      top3_2.foreach(println)
      

      /*
      start = System.currentTimeMillis
      println(rddFromFile.count)
      println("elapsed time: " + (System.currentTimeMillis - start) + " msec")
      */

      /*
      var counter = 0
      rdd.foreach(f=>{
      println("Col1: "+ f(0) + ",Col2: "+ f(1))
      })
      */
      
      sc.stop()
  }
}

