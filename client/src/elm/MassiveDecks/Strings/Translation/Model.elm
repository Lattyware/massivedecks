module MassiveDecks.Strings.Translation.Model exposing (..)

import Html exposing (Html)
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages.Model exposing (Language)


{-| A result of translating an `MdString`.
-}
type Result context
    = Ref (Maybe context) MdString -- A reference to another string.
    | Raw (Maybe context) MdString -- A reference to another string as raw text - no enhancement will be done. Generally avoid.
    | Text String -- The given static text.
    | Em (List (Result context)) -- The contained text will be emphasised if possible (e.g: bold).
    | Segment (List (Result context)) -- Indicates a "line" of text that will be wrapped independently (but not actively line broken).
    | Missing -- Indicates that this string hasn't been translated.


{-| The details of a language.
-}
type alias PackDefinition langContext =
    -- The Elm identifier for the language.
    { lang : Language

    -- The function to translate `MdString`s for the language.
    , translate : Maybe langContext -> MdString -> List (Result langContext)

    -- The IETF language tag for the language.
    , code : String

    -- The name that describes the language.
    , name : MdString

    -- A deck to recommend to users if they haven't added one.
    , recommended : Source.External
    }


{-| The details of a language, with language-specific context resolved out.
-}
type alias Pack =
    -- The IETF language tag for the language.
    { code : String

    -- The name that describes the language.
    , name : MdString

    -- A deck to recommend to users if they haven't added one.
    , recommended : Source.External

    -- Translate the given string to HTML.
    , html : Shared -> MdString -> Html Never

    -- Translate the given string to a raw string.
    , string : Shared -> MdString -> String
    }
