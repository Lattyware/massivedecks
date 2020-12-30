module MassiveDecks.Strings.Translation exposing (pack)

import MassiveDecks.Strings.Render as Render
import MassiveDecks.Strings.Translation.Model exposing (..)


{-| Get a language pack from the given definition.
-}
pack : PackDefinition langContext -> Pack
pack def =
    let
        context mdString =
            { lang = def.lang, translate = def.translate, parent = mdString }
    in
    { code = def.code
    , name = def.name
    , recommended = def.recommended
    , html = \shared str -> Render.asHtml shared (context str) str
    , string = \str -> Render.asString (context str) str
    }
