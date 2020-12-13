import org.apache.spark.SparkContext
import scala.util.control.Breaks

object Main {
  def main(args: Array[String]) {

      val sc = new SparkContext("local[*]", "App") 

      val b = new Breaks

      var start = System.currentTimeMillis
      val rddFromFile = sc.textFile("hdfs://192.168.76.216:9000/user/hadoop/xaa.h") 
      val rdd = rddFromFile.map(f=>{
      	  f.split(",")
      })
      println("elapsed time: " + (System.currentTimeMillis - start) + " msec")

      start = System.currentTimeMillis
      println(rddFromFile.count)
      println("elapsed time: " + (System.currentTimeMillis - start) + " msec")

      /*
      var counter = 0
      rdd.foreach(f=>{
      println("Col1: "+ f(0) + ",Col2: "+ f(1))
      })
      */
      sc.stop()
  }
}

