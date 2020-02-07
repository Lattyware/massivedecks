module MassiveDecks.Pages.Lobby.Configure.ConfigOption.Toggleable exposing
    ( Toggleable
    , bool
    , map
    , maybe
    , none
    )


type alias Toggleable value =
    Maybe
        { on : value
        , off : value
        }


maybe : value -> Toggleable (Maybe value)
maybe default =
    Just { on = Just default, off = Nothing }


bool : Toggleable Bool
bool =
    Just { on = True, off = False }


map : (value -> wrapped) -> Toggleable value -> Toggleable wrapped
map f =
    Maybe.map (\{ on, off } -> { on = f on, off = f off })


none : Toggleable value
none =
    Nothing
