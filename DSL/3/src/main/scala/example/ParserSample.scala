package example
import scala.io.Source

object ParserSample extends App {

val parser = new IniParser
var linesA = ""

/*
var source = Source.fromFile("filename")
val lines = source.getLines
linesA = linesA + lines
lines.foreach(println)
source.close
*/

val s = Source.fromFile("filename")
try {
  for (line <- s.getLines) {
      // println(line)
      linesA = linesA + line + "\n"
        }
	} finally {
	  s.close
}

print(linesA)

// var text1=Source.fromFile("filename").getLines.toString
// println(text1)

// INIファイルをパース（戻り値はParseResult[ASTSections]）
val result = parser.parseAll(parser.sections, linesA)

/*
val result = parser.parseAll(parser.sections, """
[db1]
driver=org.postgresql.Driver
url=jdbc:postgresql://localhost/testdb1
user=postgres
password=postgres

[db2]
driver=org.postgresql.Driver
url=jdbc:postgresql://localhost/testdb2
user=postgres
password=postgres
""")
*/

  // ParseResultからASTSectionsを取得
  val sections = result.get

  // ASTをMapに変換
  val map = sections.sections.map { section =>
    (section.name.string -> section.properties.map { property =>
      (property.key.string -> property.value.string)
    }.toMap)
  }.toMap

  // val a = map(section)
  // println(map.get("77943409"))

  map.foreach { e =>
  	      // println(map.get(e._1))
	      val map2 = map.get(e._1)

	      map2.foreach { f =>
	        // println(f)

		val s = f.toList
		// val str = s.toString
		
		f match {
		      // case map => println(f)
		      case map => { val g = f("subtype")
		      	       	    // println(g)
		      	       	    
		      	       	    g.toString match {
				    case "vulnerability" => println("[FOUND - vlun] " + f)
				    case _ => // println(g)
				    }
				  
		      } 
		      	   
		      
		      }

		/*
	      	if(map2.get("subtype") == "spyware")
		{
		 println(map2)
		}
		*/
              }
	      
  }
	      

/*
  map.foreach { e =>
  	      map.get(e._1).foreach { f =>
	      	println(e._1)
		}
	      }
*/
}

import scala.util.parsing.combinator.RegexParsers

class IniParser extends RegexParsers {

  // 文字列（[、]、=、空白文字）を含まない
  def string :Parser[ASTString] = """[^\[\]=\s]*""".r^^{
    case value => ASTString(value)
  }

  /*
  def string :Parser[ASTString] = """[^\[\]=\s]*""".r^^{
    case value => ASTString(value)
  }
  */

  // プロパティ
  def property :Parser[ASTProperty] = string~"="~string^^{
    case (key~_~value) => ASTProperty(key, value)
  }

  // セクション
  def section :Parser[ASTSection] = "["~>string~"]"~rep(property)^^{
    case (section~_~properties) => ASTSection(section, properties)
  }

  // セクションの集合
  def sections :Parser[ASTSections] = rep(section)^^{
    case sections => ASTSections(sections)
  }
}

trait AST

// 文字列
case class ASTString(string: String) extends AST
// プロパティ
case class ASTProperty(key: ASTString, value: ASTString) extends AST
// セクション
case class ASTSection(name: ASTString, properties: List[ASTProperty]) extends AST
// セクションの集合（ファイル全体）
case class ASTSections(sections: List[ASTSection]) extends AST
