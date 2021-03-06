package actors

import actors.TableRegistry.{AddTables, ListTables, TableById}
import akka.actor.{Actor, Props}
import models.Table
import play.api.Logger

class TableRegistry extends Actor {

  private val logger = Logger("application")

  def receive: Receive = active(Map.empty)

  def active(registry: Map[Int, Table]): Receive = {

    case AddTables(tables) =>
      val newKeyVals = tables.map { t =>
        t.id -> t
      }
      val newRegistry = registry ++ newKeyVals
      context become active(newRegistry)

    case TableById(tableId) =>
      val matchingTable = registry.get(tableId)
      if (matchingTable.isEmpty) {
        val tableResults = registry.values.map { table =>
          (table.id, table.tableName)
        }
        logger.info(s"Missing Table: $tableId from $tableResults")
      }
      sender() ! matchingTable

    case ListTables =>
      sender() ! registry.values.toSeq
  }

}

object TableRegistry {
  val props: Props = Props[TableRegistry]()

  case class TableById(tableId: Int)
  case class AddTables(tables: Seq[Table])
  case object ListTables {}
}
