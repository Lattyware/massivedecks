module MassiveDecks.Card.Source.Methods exposing
    ( ExternalGeneralMethods
    , ExternalMethods
    , GeneralMethods
    , IsGeneralExternal
    , IsSpecific
    , IsSpecificExternal
    , Methods
    )

import Html exposing (Html)
import MassiveDecks.Card.Source.Model exposing (..)
import MassiveDecks.Components.Form.Message exposing (Message)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Decks.Model exposing (DeckOrError)
import MassiveDecks.Strings exposing (MdString)


{-| A collection of methods applied to a specific source.

The methods are as follows:

  - `defaultDetails`: Get the default placeholder details for the specific source, until the real details are loaded.
  - `tooltip`: A tooltip to display on hover for the specific source, if one makes sense.
  - `general`: The general methods for sources of this type.

-}
type alias Methods msg =
    IsSpecific (GeneralMethods msg) msg


{-| A collection of methods applied to a specific external source.

The methods are as follows:

  - `rest`: Get the methods not specific to external sources.
  - `general`: The general methods for sources of this type.
  - `editor`: An editor for the source to allow the user to create/edit a reference to one.
  - `equals`: Test if two sources are the same (and should therefore be deduplicated, for example).
  - `problems`: Any problems with the given specific source. If this returns any problems, then the source is considered invalid.

-}
type alias ExternalMethods msg =
    IsSpecificExternal (IsSpecific (ExternalGeneralMethods msg) msg) msg


{-| A collection of methods that apply generally to any source of the given type.

The methods are as follows:

  - `name`: A general name for the source.
  - `logo`: A logo for the source, if there is one.

-}
type alias GeneralMethods msg =
    { name : () -> MdString
    , logo : () -> Maybe (Html msg)
    , messages : () -> List (Message msg)
    }


{-| A collection of methods that apply generally to any external source of the given type.

The methods are as follows:

  - `rest`: Get the general methods not specific to external sources.
  - `empty`: A source with no value (doesn't have to validate) that can be used as an initial value for the editor.

-}
type alias ExternalGeneralMethods msg =
    IsGeneralExternal (GeneralMethods msg)


{-| Specific methods.
-}
type alias IsSpecific general msg =
    { general
        | tooltip : (String -> List (Html msg) -> Html msg) -> Maybe ( String, Html msg )
        , defaultDetails : Shared -> Details
    }


{-| Specific external methods.
-}
type alias IsSpecificExternal general msg =
    { general
        | editor : Shared -> List DeckOrError -> (External -> msg) -> Maybe msg -> msg -> Html msg
        , equals : External -> Bool
        , problems : () -> List (Message msg)
    }


{-| General external methods.
-}
type alias IsGeneralExternal rest =
    { rest
        | empty : Shared -> External
        , id : () -> General
    }
