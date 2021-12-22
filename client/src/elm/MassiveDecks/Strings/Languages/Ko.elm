module MassiveDecks.Strings.Languages.Ko exposing (pack)

{-| English localization.

This is the primary language, strings here are the canonical representation, and are suitable to translate from.

-}

import MassiveDecks.Card.Source.BuiltIn.Model as BuiltIn
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Strings exposing (MdString(..), Noun(..), Quantity(..))
import MassiveDecks.Strings.Languages.En.Internal as Internal
import MassiveDecks.Strings.Languages.Model exposing (Language(..))
import MassiveDecks.Strings.Translation as Translation
import MassiveDecks.Strings.Translation.Model as Translation exposing (Result(..))


pack : Translation.Pack
pack =
    Translation.pack
        { lang = Ko
        , code = "ko"
        , name = Korean
        , translate = Internal.translate
{-|       , recommended = "cah-base-en" |> BuiltIn.Id |> Source.BuiltIn -- Change this if you add a new built-in deck for the language. -}
        , recommended = "cah-base-en" |> BuiltIn.hardcoded |> Source.BuiltIn
        }



{-
   Because it is used as a default, the english translation is in `En.Internal`, rather than residing in this file
   as with most languages. Please look there for the strings.
-}
