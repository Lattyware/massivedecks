module MassiveDecks.Strings.Languages exposing
    ( alt
    , autonym
    , code
    , currentLanguage
    , defaultLanguage
    , findBestMatch
    , fromCode
    , givenLanguageString
    , html
    , label
    , languageName
    , languages
    , placeholder
    , string
    , title
    )

{-| The primary entry point to I18N for Massive Decks.
-}

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings exposing (MdString(..))
import MassiveDecks.Strings.Languages.En as EnLang
import MassiveDecks.Strings.Languages.Model exposing (..)
import MassiveDecks.Strings.Render as Render
import MassiveDecks.Strings.Translation as Translation
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Util.String as String
import Weightless.Attributes as WlA


{-| A list of all the languages enabled in the application, in the order they will be presented to the end-user.
-}
languages : List Language
languages =
    [ En
    ]


{-| The IETF language tag for the language.
-}
code : Language -> String
code language =
    language |> pack |> .code


{-| Get the language from an IETF language tag. This only finds exact matches.
-}
fromCode : String -> Maybe Language
fromCode c =
    languagesDict |> Dict.get c


{-| Every language must have a string that describes itself.
-}
languageName : Language -> MdString
languageName language =
    language |> pack |> .name


{-| The given language's name for itself.
-}
autonym : Language -> String
autonym language =
    languageName language |> givenLanguageString language


{-| The language the user is currently seeing the page in.
-}
currentLanguage : Shared -> Language
currentLanguage shared =
    Maybe.first [ shared.settings.settings.chosenLanguage, shared.browserLanguage ] |> Maybe.withDefault defaultLanguage


{-| The language selected by default.
-}
defaultLanguage : Language
defaultLanguage =
    En


{-| Takes a list of IETF language tags and gives back the best language match, if any.
-}
findBestMatch : List String -> Maybe Language
findBestMatch codes =
    -- TODO: Standardising & Fuzzy matching like https://github.com/LuminosoInsight/langcodes
    Maybe.first (codes |> List.map fromCode)


{-| Build an actual string from an `MdString` in the user's language.
-}
string : Shared -> MdString -> String
string shared mdString =
    mdString |> givenLanguageString (currentLanguage shared)


{-| Build an actual string in the given language.
-}
givenLanguageString : Language -> MdString -> String
givenLanguageString lang mdString =
    mdString |> Render.asString ( lang, translate lang )


{-| An HTML text node from the given `MdString`. Note this is more than just convenience - we enhance some strings
with rich HTML content (e.g: links, icons, etc...) when rendered as HTML.
-}
html : Shared -> MdString -> Html msg
html shared mdString =
    let
        lang =
            currentLanguage shared
    in
    mdString |> Render.asHtml ( lang, translate lang )


{-| Convenience for an HTML `placeholder` attribute from the given `MdString`.
-}
placeholder : Shared -> MdString -> Html.Attribute msg
placeholder shared =
    string shared >> String.capitalise >> HtmlA.placeholder


{-| Convenience for an HTML `title` attribute from the given `MdString`.
-}
title : Shared -> MdString -> Html.Attribute msg
title shared =
    string shared >> String.capitalise >> HtmlA.title


{-| Convenience for an HTML `alt` attribute from the given `MdString`.
-}
alt : Shared -> MdString -> Html.Attribute msg
alt shared =
    string shared >> String.capitalise >> HtmlA.alt


{-| Convenience for an Weightless `label` attribute from the given `MdString`.
-}
label : Shared -> MdString -> Html.Attribute msg
label shared =
    string shared >> String.capitalise >> WlA.label



{- Private -}


translate : Language -> MdString -> List Translation.Result
translate lang mdString =
    mdString |> (pack lang |> .translate)


languagesDict : Dict String Language
languagesDict =
    Dict.fromList (languages |> List.map (\l -> ( code l, l )))


pack : Language -> Translation.Pack
pack language =
    case language of
        En ->
            EnLang.pack
