import akka.actor._
import scala.collection.mutable.ListBuffer
import com.typesafe.config.ConfigFactory
// import org.apache.spark.Logging
import scala.io.Source
import akka.event.Logging

import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.storage.StorageLevel
import org.apache.log4j.{Level, Logger}

case class SimpleFeedActorConfig(hostname: String = "localhost",
                                 port: Int = 12345,
                                 interval: Int = 500,
                                 inputFile: String = "input")

case class SubscribeReceiver(receiverActor: ActorRef)

case class UnsubscribeReceiver(receiverActor: ActorRef)

class SimpleFeederActor(inputFile: String, interval: Int) extends Actor with ActorLogging {

  var receivers = List.empty[ActorRef]

  new Thread() {
    override def run() {
      println("Start processing")

      lazy val dataSource = Source.fromFile(inputFile) 

      try{
        while(true) {
          for (line <- dataSource.getLines) {
            Thread.sleep(interval)
            // logInfo(s"$line")
            receivers.foreach(_ ! line)
          }
        }
      } finally {
        dataSource.close()
      }
    }
  }.start()

  def receive: Receive = {

    case SubscribeReceiver(receiverActor: ActorRef) =>
      println("received subscribe from %s".format(receiverActor.toString))
      receivers = receiverActor +: receivers

    case UnsubscribeReceiver(receiverActor: ActorRef) =>
      println("received unsubscribe from %s".format(receiverActor.toString))
      receivers = receivers.dropWhile(x => x eq receiverActor)

  }
}

object SimpleFeedActor {

  def main(args: Array[String]) {
    val parser = new scopt.OptionParser[SimpleFeedActorConfig]("SimpleFeedActor") {
      arg[String]("hostname") required() action {
        (x, c) => c.copy(hostname = x)
      } text("The hostname to accept connections from remote hosts")

      arg[Int]("port") required() action {
        (x, c) => c.copy(port = x)
      } text("The port number to accept connections from remote hosts")

      arg[Int]("interval") required() action {
        (x, c) => c.copy(interval = x)
      } text("The interval to send messages to remote hosts [msec]")

      arg[String]("inputFile") required() action {
        (x, c) => c.copy(inputFile = x)
      } text("The path of the input file")

    }

    parser.parse(args, SimpleFeedActorConfig()) exists { config =>
      val akkaConf = ConfigFactory.parseString(
        s"""
           |akka.actor.provider = "akka.remote.RemoteActorRefProvider"
           |akka.remote.netty.tcp.transport-class = "akka.remote.transport.netty.NettyTransport"
           |akka.remote.netty.tcp.hostname = "${config.hostname}"
           |akka.remote.netty.tcp.port = ${config.port}
           |akka.remote.netty.tcp.tcp-nodelay = on
     """.stripMargin
      )
      val actorSystem = ActorSystem.create("test", akkaConf)
      val feeder = actorSystem.actorOf(Props(new SimpleFeederActor(config.inputFile, config.interval)), "Feeder")

      println("Feeder started as:" + feeder)

      // actorSystem.awaitTermination()
      // Await.result(system.whenTerminated, timeout)
      actorSystem.terminate()

      true
    }
  }

}
