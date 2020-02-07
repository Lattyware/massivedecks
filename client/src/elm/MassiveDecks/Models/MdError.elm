module MassiveDecks.Models.MdError exposing
    ( ActionExecutionError(..)
    , AuthenticationError(..)
    , GameStateError(..)
    , LobbyNotFoundError(..)
    , MdError(..)
    , RegistrationError(..)
    , describe
    , shortDescribe
    )

import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Round as Round
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.User as User


type MdError
    = ActionExecution ActionExecutionError
    | Authentication AuthenticationError
    | LobbyNotFound { reason : LobbyNotFoundError, gameCode : GameCode }
    | Registration RegistrationError
    | Game GameStateError


type ActionExecutionError
    = IncorrectPlayerRole { role : Player.Role, expected : Player.Role }
    | IncorrectUserRole { role : User.Role, expected : User.Role }
    | IncorrectRoundStage { stage : Round.Stage, expected : Round.Stage }
    | ConfigEditConflict { version : String, expected : String }
    | Unprivileged
    | GameNotStarted
    | InvalidAction { reason : String }


type AuthenticationError
    = IncorrectIssuer
    | InvalidAuthentication
    | InvalidLobbyPassword
    | AlreadyLeftError


type LobbyNotFoundError
    = Closed
    | DoesNotExist


type RegistrationError
    = UsernameAlreadyInUseError { username : String }


type GameStateError
    = OutOfCardsError


shortDescribe : MdError -> MdString
shortDescribe error =
    case error of
        ActionExecution _ ->
            Strings.ActionExecutionError

        Authentication _ ->
            Strings.AuthenticationError

        LobbyNotFound _ ->
            Strings.LobbyNotFoundError

        Registration _ ->
            Strings.RegistrationError

        Game _ ->
            Strings.GameError


describe : MdError -> MdString
describe error =
    case error of
        ActionExecution aee ->
            case aee of
                IncorrectPlayerRole { role, expected } ->
                    Strings.IncorrectPlayerRoleError { role = Player.roleDescription role, expected = Player.roleDescription expected }

                IncorrectUserRole { role, expected } ->
                    Strings.IncorrectUserRoleError { role = User.roleDescription role, expected = User.roleDescription expected }

                IncorrectRoundStage { stage, expected } ->
                    Strings.IncorrectRoundStageError { stage = Round.stageDescription stage, expected = Round.stageDescription expected }

                ConfigEditConflict _ ->
                    Strings.ConfigEditConflictError

                Unprivileged ->
                    Strings.UnprivilegedError

                GameNotStarted ->
                    Strings.GameNotStartedError

                InvalidAction { reason } ->
                    Strings.InvalidActionError { reason = reason }

        Authentication ae ->
            case ae of
                IncorrectIssuer ->
                    Strings.IncorrectIssuerError

                InvalidAuthentication ->
                    Strings.InvalidAuthenticationError

                InvalidLobbyPassword ->
                    Strings.InvalidLobbyPasswordError

                AlreadyLeftError ->
                    Strings.AlreadyLeftError

        LobbyNotFound { reason, gameCode } ->
            case reason of
                Closed ->
                    Strings.LobbyClosedError { gameCode = GameCode.toString gameCode }

                DoesNotExist ->
                    Strings.LobbyDoesNotExistError { gameCode = GameCode.toString gameCode }

        Registration reason ->
            case reason of
                UsernameAlreadyInUseError { username } ->
                    Strings.UsernameAlreadyInUseError { username = username }

        Game gse ->
            case gse of
                OutOfCardsError ->
                    Strings.OutOfCardsError
