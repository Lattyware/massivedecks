module MassiveDecks.Models.MdError exposing
    ( ActionExecutionError(..)
    , AuthenticationError(..)
    , GameStateError(..)
    , LobbyNotFoundError(..)
    , MdError(..)
    )

import MassiveDecks.Game.Player as Player
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.User as User


type MdError
    = ActionExecution ActionExecutionError
    | Authentication AuthenticationError
    | LobbyNotFound { reason : LobbyNotFoundError, gameCode : GameCode }
    | Game GameStateError


type ActionExecutionError
    = IncorrectPlayerRole { role : Player.Role, expected : Player.Role }
    | IncorrectUserRole { role : User.Role, expected : User.Role }
    | IncorrectRoundStageError { stage : String, expected : String }
    | ConfigEditConflictError { version : String, expected : String }
    | Unprivileged
    | GameNotStarted


type AuthenticationError
    = IncorrectIssuer
    | InvalidAuthentication
    | InvalidLobbyPassword


type LobbyNotFoundError
    = Closed
    | DoesNotExist


type GameStateError
    = OutOfCardsError
