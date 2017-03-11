module MassiveDecks.Scenes.Playing.HouseRule exposing (HouseRule, Action)

import MassiveDecks.Scenes.Playing.HouseRule.Id exposing (Id)
import MassiveDecks.Scenes.Playing.Messages as Playing
import MassiveDecks.Scenes.Lobby.Models as Lobby


type alias HouseRule =
    { id : Id
    , icon : String
    , name : String
    , description : String
    , actions : List Action
    }


type alias Action =
    { icon : String
    , text : String
    , description : String
    , onClick : Playing.Message
    , enabled : Lobby.Model -> Bool
    }
