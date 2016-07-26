package massivedecks.lobby

import scala.concurrent.duration._
import scala.concurrent.{ExecutionContext, Future}
import scala.util.Random

import massivedecks.models.Game._
import massivedecks.exceptions.BadRequestException
import massivedecks.models.{Errors, Player}
import massivedecks.notifications.Notifiers
import massivedecks.Util

/**
  * The state of the game.
  *
  * @param players The players in the lobby the game is in.
  * @param config The configuration for the lobby the game is in.
  * @param notifiers The notifiers for the lobby the game is in.
  */
class Game(players: Players, config: Config, notifiers: Notifiers) (implicit context: ExecutionContext) {

  import Game._

  /**
    * The history of the game.
    */
  var history: List[Round.Finished] = List()

  private val deck: Deck = Deck(config.decks)
  private var czarIndex = 0
  private var hands: Map[Player.Id, Hand] = players.ids.map(id => {
    val hand = new Hand(deck.drawResponses(Hand.size))
    notifiers.handChange(id, hand)
    id -> hand
  }).toMap
  private var roundProgress: RoundProgress = Playing
  private var roundTimedOut: Boolean = false

  // Initial values overwritten by beginRound() call below, just keeping the compiler happy.
  private var czar: Player.Id = Player.Id(0)
  private var call: Call = deck.drawCall()
  private var playedCards: Map[Player.Id, Option[List[Response]]] = Map()
  beginRound(true)

  /**
    * @return The ids of the players that are taking part in the current round.
    */
  def playersInRound = playedCards.keySet

  /**
    * @return The model representing the current round.
    */
  def round: Round = roundProgress match {
    case Playing =>
      Round(czar, call, Round.State.Playing(roundTimedOut, numberOfPlayersWhoHavePlayed))
    case Judging(shuffled, _) =>
      Round(czar, call, Round.State.Judging(roundTimedOut, shuffled))
    case Finished(shuffled, playedOrder, winner) =>
      Round(czar, call, Round.State.Finished(shuffled, PlayedByAndWinner(playedOrder, winner)))
  }

  /**
    * Add a player to the game, giving them a hand.
    *
    * @param playerId The id of the player to add.
    */
  def addPlayer(playerId: Player.Id): Unit = {
    hands += (playerId -> Hand(deck.drawResponses(Hand.size)))
  }

  /**
    * Remove a player from the game, removing their hand and any played cards for the round.
    * Note this may invalidate the round (if the player is the czar) or finish the round.
    *
    * @param playerId The id of the player to remove.
    */
  def playerLeft(playerId: Player.Id): Unit = {
    hands = hands.filterKeys(id => id != playerId)
    playedCards = playedCards.filterKeys(id => id != playerId)
    if (playerId == round.czar) {
      invalidateRound()
    } else {
      checkIfFinishedPlaying()
    }
  }

  /**
    * Begin the round.
    *
    * @param firstRound If this is the first round in the game.
    * @throws BadRequestException with key "not-enough-players" if there are not enough players in the game to begin a
    *                             round. The value "required" gives the minimum number of players needed for the request
    *                             to succeed.
    */
  def beginRound(firstRound: Boolean = false) = {
    if (players.amount < Players.minimum) {
      throw BadRequestException(Errors.NotEnoughPlayers(Players.minimum))
    }

    czar = nextCzar()
    call = deck.drawCall()

    if (firstRound) {
      notifiers.gameStart(czar, call)
    } else {
      notifiers.roundStart(czar, call)
    }

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

    startRoundTimer(round.state.getClass, call)
    checkIfFinishedPlaying()
  }

  private def getIdsForFirstXCardsInHand(playerId: Player.Id, amount: Int): List[String] = {
    val hand = hands(playerId).hand
    (0 until amount).map(i => hand(i).id).toList
  }

  private def startRoundTimer(state: Class[_ <: Round.State], call: Call) = Future {
    roundTimedOut = false
    Util.wait(Game.roundTimeLimit)
    if (state.isInstance(round.state) && round.call == call) {
      roundTimedOut = true
      notifiers.roundTimeLimitHit()
    }
  }

  /**
    * Play the given cards into the round.
    *
    * @param playerId The player the play is for.
    * @param cardIds The ids of the responses to play.
    * @throws BadRequestException with key "not-in-round" if the player is not in the round.
    * @throws BadRequestException with key "already-played" if the player has already played into the round.
    * @throws BadRequestException with key "already-judging" if the round is already in it's judging state.
    * @throws BadRequestException with key "wrong-number-of-cards-played" if the wrong number of responses were played.
    *                             The value "got" is the number of cards played, the value "expected" is the number
    *                             required for the request to succeed
    * @throws BadRequestException with key "invalid-card-id-given" if any of the card ids are not in the given player's
    *                             hand.
    */
  def play(playerId: Player.Id, cardIds: List[String]): Unit = {
    BadRequestException.verify(playersInRound.contains(playerId), Errors.NotInRound())
    BadRequestException.verify(playedCards(playerId).isEmpty, Errors.AlreadyPlayed())
    BadRequestException.verify(roundProgress == Playing, Errors.AlreadyJudging())
    BadRequestException.verify(cardIds.length == call.slots, Errors.WrongNumberOfCardsPlayed(cardIds.length, call.slots))
    val hand = hands(playerId).hand
    val toPlay: List[Response] = cardIds.flatMap(id => hand.find(response => response.id == id))
    BadRequestException.verify(toPlay.length == cardIds.length, Errors.InvalidCardId())
    val toDraw = Hand.size - (hand.length - toPlay.length)
    val newHand = Hand(hand.filter(response => !toPlay.contains(response)) ++ deck.drawResponses(toDraw))
    hands += (playerId -> newHand)
    playedCards += (playerId -> Some(toPlay))
    players.updatePlayer(playerId, players.setPlayerStatus(Player.Played))
    notifiers.roundPlayed(numberOfPlayersWhoHavePlayed)
    checkIfFinishedPlaying()
  }

  /**
    * Choose the winning play for the round.
    *
    * @param playerId The player who is choosing the winner.
    * @param winner The index of the played responses being chosen.
    * @throws BadRequestException with key "not-czar" if the current player is not the czar.
    * @throws BadRequestException with key "not-judging" if the round is not yet in the judging phase.
    * @throws BadRequestException with key "no-such-played-cards" if the index does not exist.
    * @throws BadRequestException with key "already-judged" if the round is already finished.
    */
  def choose(playerId: Player.Id, winner: Int): Unit = {
    BadRequestException.verify(playerId == czar, Errors.NotCzar())
    roundProgress match {
      case Playing =>
        throw BadRequestException(Errors.NotJudging())
      case Judging(responses, playedOrder) =>
        playedOrder.lift(winner) match {
          case Some(winnerId) =>
            players.updatePlayer(winnerId, players.modifyPlayerScore(1))
            roundProgress = Finished(responses, playedOrder, winnerId)
            val finishedRound = Round.Finished(round.czar, round.call, Round.State.Finished(responses, PlayedByAndWinner(playedOrder, winnerId)))
            history = finishedRound :: history
            notifiers.roundEnd(finishedRound)

          case None =>
            throw BadRequestException(Errors.NoSuchPlayedCards())
        }
      case Finished(_, _, _) =>
        throw BadRequestException(Errors.AlreadyJudged())
    }
  }

  /**
    * Get the hand of the given player.
    *
    * @param playerId The id of the player.
    * @return The hand for the player.
    */
  def getHand(playerId: Player.Id): Hand = hands(playerId)

  /**
    * Redraw the hand of the given player.
    *
    * @param playerId The id of the player.
    * @throws BadRequestException with the key "not-enough-points" if the player doesn't have enough points.
    */
  def redraw(playerId: Player.Id): Unit = {
    val player = players.getPlayer(playerId)
    BadRequestException.verify(player.score > 0, Errors.NotEnoughPoints())
    players.updatePlayer(playerId, players.modifyPlayerScore(-1))
    hands += (playerId -> Hand(deck.drawResponses(Hand.size)))
  }

  /**
    * Start skipping the given players.
    *
    * @param playerId The player requesting the skipping.
    * @param playerIds The players to start skipping.
    */
  def skip(playerId: Player.Id, playerIds: Set[Player.Id]): Unit = {
    for (id <- playerIds) {
      players.updatePlayer(id, players.setPlayerStatus(Player.Skipping))
      playedCards = playedCards.filterKeys(pId => pId != id)
    }
    if (playerIds.contains(round.czar)) {
      invalidateRound()
    } else {
      checkIfFinishedPlaying()
    }
  }

  private def invalidateRound(): Unit = {
    beginRound()
  }

  private def checkIfFinishedPlaying(): Unit = {
    if (roundProgress == Playing && playedCards.values.forall(item => item.isDefined)) {
      roundTimedOut = false
      startRoundTimer(round.state.getClass, round.call)
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
  val roundTimeLimit = 120.seconds

  /**
    * Represents the progress through a round.
    */
  sealed trait RoundProgress

  /**
    * Indicates the game is being played.
    */
  case object Playing extends RoundProgress

  /**
    * Indicates the round is being judged.
    *
    * @param shuffled The shuffled list of played responses.
    * @param playedOrder A list of player ids for the players who played the responses matching the order shuffled.
    */
  case class Judging(shuffled: List[List[Response]], playedOrder: List[Player.Id]) extends RoundProgress

  /**
    * Indicates the round is done.
    *
    * @param shuffled The shuffled list of played responses.
    * @param playedOrder A list of player ids for the players who played the responses matching the order shuffled.
    * @param winner The id of the winner of the round.
    */
  case class Finished(shuffled: List[List[Response]], playedOrder: List[Player.Id], winner: Player.Id) extends RoundProgress
}
