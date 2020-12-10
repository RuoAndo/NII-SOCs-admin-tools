name := "App"
version := "1.0"
scalaVersion := "2.11.12"

libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % "2.2.0",
  "org.apache.spark" %% "spark-sql" % "2.1.2",
  "com.databricks" %% "spark-csv" % "1.0.3",
  "org.apache.logging.log4j" % "log4j-core" % "2.14.0" 
)

