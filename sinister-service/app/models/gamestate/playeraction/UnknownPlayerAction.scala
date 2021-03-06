package models.gamestate.playeraction

import io.circe.generic.semiauto.deriveDecoder
import io.circe.{Decoder, Encoder, Json}
import models.HandPlayer
import models.gamestate.HandEvent
import play.api.Logger

case class UnknownPlayerAction(subAction: Int, rawJson: Json)
    extends PlayerAction
    with HandEvent {
  override val seatIndex: Int = -1
  val encoded: Json = UnknownPlayerAction.encoder(this)

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = s"Unknown Player action ${rawJson.toString()}"
}

object UnknownPlayerAction {
  val logger = Logger("application")

  implicit val encoder: Encoder.AsObject[UnknownPlayerAction] =
    Encoder.forProduct3(
      "undefinedPlayerAction",
      "subAction",
      "source"
    ) { source =>
      {
        (true, source.subAction, source.rawJson)
      }
    }

  implicit val decoder: Decoder[UnknownPlayerAction] = deriveDecoder
}
