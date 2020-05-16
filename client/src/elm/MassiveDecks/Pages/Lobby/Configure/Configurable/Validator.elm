module MassiveDecks.Pages.Lobby.Configure.Configurable.Validator exposing
    ( Def
    , Validator
    , between
    , nonEmpty
    , none
    , whenJust
    )

import FontAwesome.Solid as Icon
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Strings as Strings
import MassiveDecks.Util.Maybe as Maybe


type alias Def value msg =
    (value -> msg) -> Validator value msg


type alias Validator value msg =
    value -> List (Message msg)


whenJust : Def value msg -> Def (Maybe value) msg
whenJust base set value =
    value |> Maybe.map (base (Just >> set)) |> Maybe.withDefault []


between : Int -> Int -> Def Int msg
between min max set value =
    List.filterMap identity
        [ Message.errorWithFix (Strings.MustBeMoreThanOrEqualValidationError { min = min })
            [ { description = Strings.SetValue { value = min }
              , action = set min
              , icon = Icon.arrowUp
              }
            ]
            |> Maybe.justIf (value < min)
        , Message.errorWithFix (Strings.MustBeLessThanOrEqualValidationError { max = max })
            [ { description = Strings.SetValue { value = max }
              , action = set max
              , icon = Icon.arrowDown
              }
            ]
            |> Maybe.justIf (value > max)
        ]


nonEmpty : Def String msg
nonEmpty _ value =
    let
        len =
            String.length value
    in
    List.filterMap identity [ Message.error Strings.CantBeEmpty |> Maybe.justIf (len < 1) ]


none : Def value msg
none _ _ =
    []
