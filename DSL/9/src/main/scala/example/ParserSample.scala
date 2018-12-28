package example
import scala.io.Source

import org.json4s._
import org.json4s.JsonDSL._
import org.json4s.jackson.JsonMethods._

object ParserSample extends App {

val parser = new IniParser
var linesA = ""

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

// INIファイルをパース（戻り値はParseResult[ASTSections]）
val result = parser.parseAll(parser.sections, linesA)

  // ParseResultからASTSectionsを取得
  val sections = result.get

  // ASTをMapに変換
  val map = sections.sections.map { section =>
    (section.name.string -> section.properties.map { property =>
      (property.key.string -> property.value.string)
    }.toMap)
  }.toMap

  // println(compact(render(map)))
  println(map)

  def search( subtype: Option[String] ) {
      subtype match {
      	  case Some(name) =>
	       println("found:" + name)
	  case None =>
	       println("failed")
	       }
  }
  
  // serch(map)
  // println(map.get("77943409"))
  
  search(map("77943409").get("subtype"))
  println(map.get("77943409").get("subtype"))
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
