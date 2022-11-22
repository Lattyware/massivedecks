module MassiveDecks.Strings.Languages.Fr exposing (pack)

{-| French localization.

Contributors:

  - antoinedelia <https://github.com/antoinedelia>

-}

import MassiveDecks.Card.Source.BuiltIn.Model as BuiltIn
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Strings exposing (MdString(..), Noun(..), Quantity(..))
import MassiveDecks.Strings.Languages.Model exposing (Language(..))
import MassiveDecks.Strings.Translation as Translation
import MassiveDecks.Strings.Translation.Model as Translation exposing (Result(..))


pack : Translation.Pack
pack =
    Translation.pack
        { lang = Fr
        , code = "fr"
        , name = French
        , translate = translate
        , recommended = "cah-base-en" |> BuiltIn.hardcoded |> Source.BuiltIn
        }
