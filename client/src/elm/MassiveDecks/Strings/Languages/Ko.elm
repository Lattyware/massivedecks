module MassiveDecks.Strings.Languages.Ko exposing (pack)

{-| Korean localization.

Contributors:

  - sjkim04 <https://github.com/sjkim04>

-}

import MassiveDecks.Card.Source.BuiltIn.Model as BuiltIn
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Strings exposing (MdString(..), Noun(..), Quantity(..), noun, nounMaybe, nounUnknownQuantity)
import MassiveDecks.Strings.Languages.Model exposing (Language(..))
import MassiveDecks.Strings.Translation as Translation
import MassiveDecks.Strings.Translation.Model as Translation exposing (Result(..))


pack : Translation.Pack
pack =
    Translation.pack
        { lang = Ko
        , code = "ko-kr"
        , name = Korean
        , translate = translate
        , recommended = "cah-base-ko" |> BuiltIn.hardcoded |> Source.BuiltIn
        }



{-
   Because it is used as a default, the english translation is in `En.Internal`, rather than residing in this file
   as with most languages. Please look there for the strings.
-}
