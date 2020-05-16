module MassiveDecks.Pages.Lobby.Messages exposing (Msg(..))

import MassiveDecks.Animated as Animated
import MassiveDecks.Components.Menu.Model as Menu
import MassiveDecks.Game.Messages as Game
import MassiveDecks.Game.Time as Time
import MassiveDecks.Models.MdError exposing (MdError)
import MassiveDecks.Pages.Lobby.Configure.Messages as Configure
import MassiveDecks.Pages.Lobby.Events exposing (Event)
import MassiveDecks.Pages.Lobby.Model exposing (..)
import MassiveDecks.Pages.Lobby.Route exposing (Section)
import MassiveDecks.Pages.Lobby.Spectate.Messages as Spectate
import MassiveDecks.User as User


type Msg
    = GameMsg Game.Msg
    | EventReceived Event
    | ErrorReceived MdError
    | ConfigureMsg Configure.Msg
    | NotificationMsg (Animated.Msg Notification)
    | SpectateMsg Spectate.Msg
    | ToggleInviteDialog
    | SetAway User.Id
    | SetPrivilege User.Id User.Privilege
    | SetUserRole (Maybe User.Id) User.Role
    | Leave
    | Kick User.Id
    | SetTimeAnchor Time.Anchor
    | TryCast Auth
    | Copy String
    | ChangeSection (Maybe Section)
    | SetGameMenuState Menu.State
    | SetUserMenuState User.Id Menu.State
    | EndGame
    | NoOp
