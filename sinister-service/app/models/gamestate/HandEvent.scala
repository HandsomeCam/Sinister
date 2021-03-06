package models.gamestate

import io.circe.syntax.EncoderOps
import io.circe.{Decoder, Encoder}
import models.gamestate.playeraction.PlayerAction

trait HandEvent {}

object HandEvent {
  val DEAL_PLAYER = 1
  val DEAL_COMMUNITY = 2
  val BETTING_COMPLETED = 3
  val SUBTRACT_CHIPS_FROM_STACK = 4
  val TRANSFER_BUTTON = 5
  val TRANSFER_ACTION = 6
  val SUBTRACT_CHIPS_FROM_POT = 7
  val DEALER_RAKE = 8
  val PLAYER_ACTION = 9
  val WIN_HAND = 10
  val WIN_POT = 12
  val TABLE_MESSAGE = 15
  val UNKNOWN_EVENT_17 = 17
  val SHOW_HAND = 25

  val BETTING_ROUND = 100

  implicit val decodeHandEvent: Decoder[HandEvent] = for {
    eventType <- Decoder[Int].prepare(_.downField("type"))
    value <- eventType match {
      case DEAL_COMMUNITY            => DealCommunityCard.decoder
      case DEAL_PLAYER               => DealPlayerCard.decoder
      case DEALER_RAKE               => DealerRake.decoder
      case BETTING_COMPLETED         => BettingCompleted.decoder
      case PLAYER_ACTION             => PlayerAction.decoderPlayerAction
      case SHOW_HAND                 => ShowHand.decoder
      case SUBTRACT_CHIPS_FROM_POT   => SubtractChipsFromPot.decoder
      case SUBTRACT_CHIPS_FROM_STACK => SubtractChipsFromStack.decoder
      case TABLE_MESSAGE             => TableMessage.decoder
      case TRANSFER_ACTION           => TransferAction.decoder
      case TRANSFER_BUTTON           => TransferButton.decoder
      case WIN_HAND => {
        WinHand.decoder
      }
      case WIN_POT          => WinPot.decoder
      case UNKNOWN_EVENT_17 => UnknownEvent.decoder
      case BETTING_ROUND    => BettingRound.decoder
      case other => {
        ???
        Decoder.failedWithMessage(s"invalid type: $other")
      }
    }
  } yield value

  implicit val encodeHandEvent: Encoder[HandEvent] = Encoder.AsObject {
    case pa: PlayerAction =>
      pa.asJsonObject
        .add("type", PLAYER_ACTION.asJson)
    case dcc: DealCommunityCard =>
      dcc.asJsonObject.add("type", DEAL_COMMUNITY.asJson)
    case dpc: DealPlayerCard =>
      dpc.asJsonObject.add("type", DEAL_PLAYER.asJson)
    case ens: BettingCompleted =>
      ens.asJsonObject.add("type", BETTING_COMPLETED.asJson)
    case scfp: SubtractChipsFromPot =>
      scfp.asJsonObject
        .add("type", SUBTRACT_CHIPS_FROM_POT.asJson)
    case scfs: SubtractChipsFromStack =>
      scfs.asJsonObject
        .add("type", SUBTRACT_CHIPS_FROM_STACK.asJson)
    case sh: ShowHand => sh.asJsonObject.add("type", SHOW_HAND.asJson)
    case tm: TableMessage =>
      tm.asJsonObject.add("type", TABLE_MESSAGE.asJson)
    case ta: TransferAction =>
      ta.asJsonObject
        .add("type", TRANSFER_ACTION.asJson)
    case tb: TransferButton =>
      tb.asJsonObject
        .add("type", TRANSFER_BUTTON.asJson)
    case dr: DealerRake =>
      dr.asJsonObject.add("type", DEALER_RAKE.asJson)
    case wh: WinHand =>
      wh.asJsonObject.add("type", WIN_HAND.asJson)
    case wp: WinPot =>
      wp.asJsonObject.add("type", WIN_POT.asJson)
    case br: BettingRound =>
      br.asJsonObject.add("type", BETTING_ROUND.asJson)
    case ue: UnknownEvent =>
      ue.asJsonObject.add("type", UNKNOWN_EVENT_17.asJson)
  }
}
