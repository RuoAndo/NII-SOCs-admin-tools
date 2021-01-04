import java.io._
var dir = new File(".")
var files = dir.listFiles()
for{i <- 0 to files.length-1} {
      var file = files(i)
      println(file.getName())
}