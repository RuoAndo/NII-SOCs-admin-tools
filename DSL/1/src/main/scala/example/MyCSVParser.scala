import org.apache.commons.csv._
import java.nio.charset.Charset
import java.io.File
import scala.collection.JavaConversions._

object MyCSVParser {

    def parse[A](file: File, mapDefinition: CSVRecord => A): List[A] = {
        val parser = CSVParser.parse(file, Charset.forName("UTF-8"), CSVFormat.DEFAULT.withHeader())
        val list = parser.getRecords.toList.map(mapDefinition)
        list
    }

}
