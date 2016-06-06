package controllers.massivedecks.lobby

import scala.util.Random

import models.massivedecks.Game._
import models.massivedecks.Player
import controllers.massivedecks.exceptions.BadRequestException
import controllers.massivedecks.notifications.Notifiers

class Game(players: Players, config: Config, notifiers: Notifiers) {

  import Game._

  private val deck: Deck = new Deck(config.decks)
  private var czarIndex = 0
  private var hands: Map[Player.Id, Hand] = players.ids.map(id => {
    val hand = new Hand(deck.drawResponses(Hand.size))
    notifiers.handChange(id, hand)
    id -> hand
  }).toMap
  private var roundProgress: RoundProgress = Playing
  var history: List[FinishedRound] = List()

  // Initial values overwritten by beginRound() call below, just keeping the compiler happy.
  private var czar: Player.Id = Player.Id(0)
  private var call: Call = deck.drawCall()
  private var playedCards: Map[Player.Id, Option[List[Response]]] = Map()
  beginRound()

  def playersInRound = playedCards.keySet
  def round: Round = {
    val responses = roundProgress match {
      case Playing =>
        Responses.hidden(numberOfPlayersWhoHavePlayed)
      case Judging(shuffled, _) =>
        Responses.revealed(Revealed(shuffled, None))
      case Finished(shuffled, playedOrder, winner) =>
        Responses.revealed(Revealed(shuffled, Some(PlayedByAndWinner(playedOrder, winner))))
    }
    Round(czar, call, responses)
  }

  def addPlayer(playerId: Player.Id): Unit = {
    hands += (playerId -> Hand(deck.drawResponses(Hand.size)))
  }

  def playerLeft(playerId: Player.Id): Unit = {
    hands = hands.filterKeys(id => id != playerId)
    playedCards = playedCards.filterKeys(id => id != playerId)
  }

  /**
    * Begin the round.
    * @return The list of players who played instantly (AI).
    */
  def beginRound() = {
    if (players.amount < Players.minimum) {
      throw BadRequestException.json("not-enough-players", "required" -> Players.minimum)
    }

    czar = nextCzar()
    call = deck.drawCall()

    notifiers.roundStart(czar, call)

    players.updatePlayers(players.setPlayerStatus(Player.NotPlayed))
    players.updatePlayer(czar, players.setPlayerStatus(Player.Czar))

    playedCards = (for (player <- players.players if !Player.Status.notInRound.contains(player.status) && !player.left) yield player.id -> None).toMap
    roundProgress = Playing

    val slots = call.slots
    if (slots > Hand.extraDrawAfter) {
      val toDraw = slots - Hand.extraDrawAfter + 1
      for (player <- playersInRound) {
        val hand = hands(player).hand
        val newHand = Hand(hand ++ deck.drawResponses(toDraw))
        hands += (player -> newHand)
        notifiers.handChange(player, newHand)
      }
    }

    for (ai <- players.ais) {
      play(ai.id, getIdsForFirstXCardsInHand(ai.id, call.slots))
    }
  }

  private def getIdsForFirstXCardsInHand(playerId: Player.Id, amount: Int): List[String] = {
    val hand = hands(playerId).hand
    (0 until amount).map(i => hand(i).id).toList
  }

  def play(playerId: Player.Id, cardIds: List[String]): Unit = {
    BadRequestException.verify(playersInRound.contains(playerId), "not-in-round")
    BadRequestException.verify(playedCards(playerId).isEmpty, "already-played")
    BadRequestException.verify(roundProgress == Playing, "already-judging")
    BadRequestException.verify(cardIds.length == call.slots, "wrong-number-of-cards-played", "got" -> cardIds.length, "expected" -> call.slots)
    val hand = hands(playerId).hand
    val toPlay: List[Response] = cardIds.flatMap(id => hand.find(response => response.id == id))
    BadRequestException.verify(toPlay.length == cardIds.length, "invalid-card-id-given")
    val toDraw = Hand.size - (hand.length - toPlay.length)
    val newHand = Hand(hand.filter(response => !toPlay.contains(response)) ++ deck.drawResponses(toDraw))
    hands += (playerId -> newHand)
    playedCards += (playerId -> Some(toPlay))
    players.updatePlayer(playerId, players.setPlayerStatus(Player.Played))
    notifiers.roundPlayed(playedCards.size)
  }

  def choose(playerId: Player.Id, winner: Int): Unit = {
    BadRequestException.verify(playerId == czar, "not-czar")
    roundProgress match {
      case Playing =>
        throw BadRequestException.json("not-judging")
      case Judging(responses, playedOrder) =>
        playedOrder.lift(winner) match {
          case Some(winnerId) =>
            players.updatePlayer(winnerId, players.modifyPlayerScore(1))
            roundProgress = Finished(responses, playedOrder, winnerId)
            val finishedRound = FinishedRound(round.czar, round.call, responses, PlayedByAndWinner(playedOrder, winnerId))
            history = finishedRound :: history
            notifiers.roundEnd(finishedRound)

          case None =>
            throw BadRequestException.json("no-such-played-cards")
        }
      case Finished(_, _, _) =>
        throw BadRequestException.json("already-judged")
    }
  }

  def getHand(playerId: Player.Id): Hand = hands(playerId)

  def redraw(playerId: Player.Id): Unit = {
    val player = players.getPlayer(playerId)
    BadRequestException.verify(player.score > 0, "not-enough-points-to-redraw")
    players.updatePlayer(playerId, players.modifyPlayerScore(-1))
    hands += (playerId -> Hand(deck.drawResponses(Hand.size)))
  }

  def skip(playerId: Player.Id, playerIds: Set[Player.Id]): Unit = {
    for (id <- playerIds) {
      players.updatePlayer(id, players.setPlayerStatus(Player.Skipping))
      playedCards = playedCards.filterKeys(pId => pId != id)
    }
  }

  def checkIfFinishedPlaying(): Unit = {
    if (roundProgress == Playing && playedCards.forall(item => item._2.isDefined)) {
      val shuffled = Random.shuffle(playedCards)
      val shuffledPlayedCards = shuffled.map(item => item._2.get).toList
      roundProgress = Judging(shuffledPlayedCards, shuffled.map(item => item._1).toList)
      notifiers.roundJudging(shuffledPlayedCards)
    }
  }

  private def numberOfPlayersWhoHavePlayed = {
    playedCards.values.count(played => played.isDefined)
  }

  private def nextCzar(): Player.Id = {
    if (czarIndex >= players.amount) {
      czarIndex = 0
    }
    val player = players.players(czarIndex)
    czarIndex += 1
    if (players.canBeCzar(player)) {
      nextCzar()
    } else {
      player.id
    }
  }

}
object Game {
  sealed trait RoundProgress
  case object Playing extends RoundProgress
  case class Judging(shuffled: List[List[Response]], playedOrder: List[Player.Id]) extends RoundProgress
  case class Finished(shuffled: List[List[Response]], playedOrder: List[Player.Id], winner: Player.Id) extends RoundProgress
}
