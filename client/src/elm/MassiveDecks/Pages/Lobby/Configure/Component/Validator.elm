module MassiveDecks.Pages.Lobby.Configure.Component.Validator exposing
    ( Validator
    , between
    , nonEmpty
    , none
    , optional
    )

import FontAwesome.Solid as Icon
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Strings as Strings
import MassiveDecks.Util.Maybe as Maybe


type alias Validator value iMsg msg =
    (iMsg -> msg) -> value -> List (Message msg)


between : Int -> Int -> (Int -> iMsg) -> Validator Int iMsg msg
between min max set wrap value =
    List.filterMap identity
        [ Message.errorWithFix (Strings.MustBeMoreThanOrEqualValidationError { min = min })
            [ { description = Strings.SetValue { value = min }
              , action = set min |> wrap
              , icon = Icon.arrowUp
              }
            ]
            |> Maybe.justIf (value < min)
        , Message.errorWithFix (Strings.MustBeLessThanOrEqualValidationError { max = max })
            [ { description = Strings.SetValue { value = max }
              , action = set max |> wrap
              , icon = Icon.arrowDown
              }
            ]
            |> Maybe.justIf (value > max)
        ]


nonEmpty : Validator String iMsg msg
nonEmpty _ value =
    List.filterMap identity [ Strings.CantBeEmpty |> Message.error |> Maybe.justIf (String.isEmpty value) ]


optional : Validator value iMsg msg -> Validator (Maybe value) iMsg msg
optional whenJust wrap maybeValue =
    case maybeValue of
        Just value ->
            whenJust wrap value

        Nothing ->
            []


none : Validator value iMsg msg
none _ _ =
    []
