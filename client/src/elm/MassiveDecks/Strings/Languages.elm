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
    , langAttr
    , languageName
    , languageNameOrCode
    , languages
    , recommended
    , sortClosestFirst
    , string
    , title
    )

{-| The primary entry point to I18N for Massive Decks.
-}

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings exposing (MdString(..))
import MassiveDecks.Strings.Languages.De as DeLang
import MassiveDecks.Strings.Languages.DeXInformal as DeXInformalLang
import MassiveDecks.Strings.Languages.En as EnLang
import MassiveDecks.Strings.Languages.Id as IdLang
import MassiveDecks.Strings.Languages.It as ItLang
import MassiveDecks.Strings.Languages.Model exposing (..)
import MassiveDecks.Strings.Languages.Pl as PlLang
import MassiveDecks.Strings.Languages.PtBR as PtBRLang
import MassiveDecks.Strings.Translation.Model as Translation
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Util.String as String
import Material.Attributes as Material


{-| A list of all the languages enabled in the application, in the order they will be presented to the end-user.
-}
languages : List Language
languages =
    [ En
    , It
    , PtBR
    , De
    , DeXInformal
    , Pl
    , Id
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


{-| If we know this code, display it nicely, otherwise regurgitate it.
-}
languageNameOrCode : Shared -> String -> String
languageNameOrCode shared givenCode =
    givenCode |> fromCode |> Maybe.map (languageName >> string shared) |> Maybe.withDefault givenCode


{-| The given language's name for itself.
-}
autonym : Shared -> Language -> String
autonym shared language =
    languageName language |> givenLanguageString shared language


{-| A sort that gives the closest matches first.
Currently this just puts all exact matches first.
-}
sortClosestFirst : Language -> Maybe Language -> Maybe Language -> Order
sortClosestFirst target a b =
    if a == b then
        EQ

    else if a == Just target then
        LT

    else if b == Just target then
        GT

    else
        EQ


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
    mdString |> givenLanguageString shared (currentLanguage shared)


{-| Build an actual string in the given language.
-}
givenLanguageString : Shared -> Language -> MdString -> String
givenLanguageString shared lang mdString =
    mdString |> (pack lang).string shared


{-| An HTML text node from the given `MdString`. Note this is more than just convenience - we enhance some strings
with rich HTML content (e.g: links, icons, etc...) when rendered as HTML.
-}
html : Shared -> MdString -> Html msg
html shared mdString =
    let
        lang =
            currentLanguage shared
    in
    mdString |> (pack lang).html shared |> Html.map never


{-| The lang attribute for embedding text of a different language into other text.
-}
langAttr : Language -> Html.Attribute msg
langAttr language =
    language |> code |> HtmlA.lang


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


{-| Convenience for a Material `label` attribute from the given `MdString`.
-}
label : Shared -> MdString -> Html.Attribute msg
label shared =
    string shared >> String.capitalise >> Material.label


{-| Get a deck to recommend to the user if they haven't added any.
-}
recommended : Shared -> Source.External
recommended shared =
    currentLanguage shared |> pack |> .recommended



{- Private -}


languagesDict : Dict String Language
languagesDict =
    Dict.fromList (languages |> List.map (\l -> ( code l, l )))


pack : Language -> Translation.Pack
pack language =
    case language of
        En ->
            EnLang.pack

        It ->
            ItLang.pack

        PtBR ->
            PtBRLang.pack

        De ->
            DeLang.pack

        DeXInformal ->
            DeXInformalLang.pack

        Pl ->
            PlLang.pack

        Id ->
            IdLang.pack
