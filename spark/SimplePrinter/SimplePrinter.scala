import akka.actor._
import scala.collection.mutable.ListBuffer
import com.typesafe.config.ConfigFactory
import scala.io.Source
import akka.event.Logging

import org.apache.spark.{SparkContext, SparkConf}

import org.apache.spark.streaming._
import org.apache.spark.storage.StorageLevel
import org.apache.log4j.{Level, Logger}


import scala.reflect.ClassTag

case class SimplePrinterConfig(hostname: String = "localhost", port: Int = 12345, interval: Int = 1000)
case class SubscribeReceiver(receiverActor: ActorRef)

case class UnsubscribeReceiver(receiverActor: ActorRef)      

class SimpleReceiver(urlOfPublisher: String)
  extends Actor { // with ActorHelper {

  lazy private val remotePublisher = context.actorSelection(urlOfPublisher)

  override def preStart(): Unit = remotePublisher ! SubscribeReceiver(context.self)

  def receive: PartialFunction[Any, Unit] = {
    //case msg => store(msg)
  }

  override def postStop(): Unit = remotePublisher ! UnsubscribeReceiver(context.self)

}

object SimplePrinter extends ActorLogging {
  def main(args: Array[String]) {

    val parser = new scopt.OptionParser[SimplePrinterConfig]("SimplePrinter") {
      arg[String]("hostname") required() action {
        (x, c) => c.copy(hostname = x)
      } text("The hostname to accept connections from remote hosts")

      arg[Int]("port") required() action {
        (x, c) => c.copy(port = x)
      } text("The port number to accept connections from remote hosts")

      arg[Int]("interval") required() action {
        (x,c) => c.copy(interval = x)
      } text("The interval to process data [msec]")
    }

    parser.parse(args, SimplePrinterConfig()) exists { config =>

      val sparkConf = new SparkConf().setAppName("ActorWordCount")
      val ssc = new StreamingContext(sparkConf, Milliseconds(config.interval))

      val lines = ssc.actorStream[String](
        Props(classOf[SimpleReceiver], "akka.tcp://test@%s:%s/user/Feeder".format(
          config.hostname, config.port), implicitly[ClassTag[String]]), "SampleReceiver")

      lines.print()

      ssc.start()
      // ssc.awaitTermination()
      ssc.terminate

      true
    }
  }
}
