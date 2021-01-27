package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.importer.GameStateEvent

case class ShowHand(seatIndex: Int)
    extends GameStateEvent
    with GameNarrative
    with AppliesToPlayer
    with HandEvent {}

object ShowHand {
  implicit val encoder: Encoder.AsObject[ShowHand] = deriveEncoder
  implicit val decoder: Decoder[ShowHand] = deriveDecoder
}
