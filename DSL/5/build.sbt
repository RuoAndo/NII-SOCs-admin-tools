import Dependencies._

val json4sNative = "org.json4s" %% "json4s-native" % "{latestVersion}"
val json4sJackson = "org.json4s" %% "json4s-jackson" % "{latestVersion}"

lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "com.example",
      scalaVersion := "2.12.5",
      version      := "0.1.0-SNAPSHOT"
    )),
    name := "Hello",
    libraryDependencies += scalaTest % Test, 
    libraryDependencies += "org.scala-lang.modules" %% "scala-parser-combinators" % "1.0.6",
    libraryDependencies += "org.json4s" %% "json4s-jackson" % "3.5.4"
)

