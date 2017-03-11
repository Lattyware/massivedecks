module MassiveDecks.Scenes.Playing.HouseRule.Id exposing (Id(..), toString)


type Id
    = Reboot


toString : Id -> String
toString id =
    case id of
        Reboot ->
            "reboot"
