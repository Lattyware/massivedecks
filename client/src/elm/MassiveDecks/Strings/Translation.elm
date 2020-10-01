module MassiveDecks.Strings.Translation exposing (pack)

import MassiveDecks.Strings.Render as Render
import MassiveDecks.Strings.Translation.Model exposing (..)


{-| Get a language pack from the given definition.
-}
pack : PackDefinition langContext -> Pack
pack def =
    let
        provideContext render shared mdString =
            render { lang = def.lang, translate = def.translate, parent = mdString, shared = shared } mdString
    in
    { code = def.code
    , name = def.name
    , recommended = def.recommended
    , html = provideContext Render.asHtml
    , string = provideContext Render.asString
    }
