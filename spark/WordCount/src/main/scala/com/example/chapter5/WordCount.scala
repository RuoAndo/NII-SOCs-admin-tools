package com.example.chapter5

import org.apache.spark.{SparkConf, SparkContext}

object WordCount {

  def main(args: Array[String]) {
    require (args.length >= 1,
      "ドライバプログラムの引数に単語をカウントする" +
      "ファイルへのパスを指定してください")

    val conf = new SparkConf().setAppName("test").setMaster("local");
    val sc = new SparkContext(conf)

    try {
      // 単語ごとに(単語, 出現回数)のタプルを作る
      val filePath = args(0)
      val wordAndCountRDD = sc.textFile(filePath)
                              .flatMap(_.split("[ ,.]"))
                              .filter(_.matches("""\p{Alnum}+"""))
                              .map((_, 1))
                              .reduceByKey(_ + _)
      

      // 単語ごとの出現回数をプリントする 
      wordAndCountRDD.collect.foreach(println)
    } finally {
      sc.stop()
    }
  }
}
    
