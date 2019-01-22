class URL ( val hostname:String, val portNo:Int, val path:Seq[String] ) {

      // checking with constructor
      if( hostname == null ) throw new IllegalArgumentException( "hostname is null" )
      
      def toURL = new java.net.URL( this.toString )

      override def toString = {
      	       val portString = if( portNo == 443 ) "" else ":" + portNo
      	       val pathString = if( path.isEmpty ) "" else path.mkString("/")
      	       "http://%s%s/%s" format( hostname, portString, pathString )
      }
}

object URL {
  def fromURL( url:java.net.URL) = {
      new URL ( url.getHost,
      	  if ( url.getPort == -1 ) 443 else url.getPort ,
	  url.getPath.split("/").dropWhile( _.isEmpty)
	  )
  }
}

object Main {
  def main(args: Array[String]) {
    val url = new java.net.URL("https://www.google.com")
    val urlsample = URL.fromURL( url )
    println( urlsample )
  }
}
