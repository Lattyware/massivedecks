module MassiveDecks.Strings.Translation exposing
    ( Pack
    , Result(..)
    )

import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Strings exposing (MdString)


{-| A result of translating an `MdString`.
-}
type Result
    = Ref MdString -- A reference to another string.
    | Raw MdString -- A reference to another string as raw text - no enhancement will be done. Generally avoid.
    | Text String -- The given static text.
    | Em (List Result) -- The contained text will be emphasised if possible (e.g: bold).
    | Segment (List Result) -- Indicates a "line" of text that will be wrapped independently (but not actively line broken).
    | Missing -- Indicates that this string hasn't been translated.


{-| The details of a language.
-}
type alias Pack =
    -- The function to translate `MdString`s for the language.
    { translate : MdString -> List Result

    -- The IETF language tag for the language.
    , code : String

    -- The name that describes the language.
    , name : MdString

    -- A deck to recommend to users if they haven't added one.
    , recommended : Source.External
    }
