module MassiveDecks.Pages.Lobby.Chat exposing (..)

import MassiveDecks.User as User


type alias Message =
    { content : String
    , author : User.Id
    }


type Msg
    = KeyDown Int
    | Input String
