module MassiveDecks.Strings.Render exposing (asHtml, asString)

import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import Html as Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Icon as Icon
import MassiveDecks.Strings exposing (..)
import MassiveDecks.Strings.Languages.Model exposing (Language)
import MassiveDecks.Strings.Translation as Translation
import MassiveDecks.Util.Html as Html


type alias Context =
    ( Language, MdString -> List Translation.Result )


{-| Build an actual string from an `MdString` in the user's language.
-}
asString : Context -> MdString -> String
asString context mdString =
    [ Translation.Ref mdString ] |> resultsToString context


{-| An HTML text node from the given `MdString`. Note this is more than just convenience - we enhance some strings
with rich HTML content (e.g: links, icons, etc...) when rendered as HTML.
-}
asHtml : Context -> MdString -> Html msg
asHtml context mdString =
    [ Translation.Ref mdString ] |> resultsToHtml context |> Html.span []



{- Private -}


resultsToString : Context -> List Translation.Result -> String
resultsToString context results =
    results |> List.map (resultToString context) |> String.concat


resultToString : Context -> Translation.Result -> String
resultToString context result =
    let
        ( _, translate ) =
            context

        mdStringToString =
            \mdString -> mdString |> translate |> resultsToString context

        partsToString =
            List.map (resultToString context) >> String.join ""
    in
    case result of
        Translation.Text text ->
            text

        Translation.Ref mdString ->
            mdStringToString mdString

        Translation.Raw mdString ->
            mdStringToString mdString

        Translation.Em emphasised ->
            partsToString emphasised

        Translation.Segment segment ->
            partsToString segment


resultsToHtml : Context -> List Translation.Result -> List (Html msg)
resultsToHtml context results =
    results |> List.concatMap (resultToHtml context)


resultToHtml : Context -> Translation.Result -> List (Html msg)
resultToHtml context result =
    let
        ( _, translate ) =
            context
    in
    case result of
        Translation.Ref mdString ->
            mdString |> translate |> resultsToHtml context |> enhanceHtml context mdString

        Translation.Text text ->
            [ Html.text text ]

        Translation.Raw mdString ->
            [ mdString |> translate |> resultsToString context |> Html.text ]

        Translation.Em emphasised ->
            [ Html.strong [] (emphasised |> List.concatMap (resultToHtml context)) ]

        Translation.Segment cluster ->
            [ Html.span [ HtmlA.class "segment" ] (cluster |> List.concatMap (resultToHtml context)) ]


enhanceHtml : Context -> MdString -> List (Html msg) -> List (Html msg)
enhanceHtml context mdString unenhanced =
    case mdString of
        Plural { singular } ->
            enhanceHtml context singular unenhanced

        Czar ->
            term context CzarDescription Icon.gavel unenhanced

        Call ->
            term context CallDescription Icon.callCard unenhanced

        Response ->
            term context ResponseDescription Icon.responseCard unenhanced

        Point ->
            term context PointDescription Icon.star unenhanced

        GameCodeTerm ->
            term context GameCodeDescription Icon.qrcode unenhanced

        GameCode _ ->
            [ Html.span
                [ HtmlA.class "game-code", GameCodeSpecificDescription |> asString context |> HtmlA.title ]
                unenhanced
            ]

        CardsAgainstHumanity ->
            [ Html.blankA [ HtmlA.href "https://cardsagainsthumanity.com/" ] unenhanced ]

        Pick numberOfCards ->
            [ Html.span [ HtmlA.class "instruction", PickDescription numberOfCards |> asString context |> HtmlA.title ] unenhanced ]

        Draw numberOfCards ->
            [ Html.span [ HtmlA.class "instruction", DrawDescription numberOfCards |> asString context |> HtmlA.title ] unenhanced ]

        Players ->
            term context PlayersDescription Icon.chessPawn unenhanced

        Spectators ->
            term context SpectatorsDescription Icon.eye unenhanced

        Left ->
            term context LeftDescription Icon.signOutAlt unenhanced

        Away ->
            term context AwayDescription Icon.userClock unenhanced

        Disconnected ->
            term context DisconnectedDescription Icon.ghost unenhanced

        Privileged ->
            term context PrivilegedDescription Icon.userCog unenhanced

        Ai ->
            term context AiDescription Icon.robot unenhanced

        Score _ ->
            [ Html.span [ HtmlA.class "no-wrap", (ScoreDescription |> asString context) |> HtmlA.title ] (suffixed unenhanced Icon.star) ]

        Likes _ ->
            [ Html.span [ HtmlA.class "no-wrap", (LikesDescription |> asString context) |> HtmlA.title ] (suffixed unenhanced Icon.thumbsUp) ]

        NumberOfCards _ ->
            [ Html.span [ HtmlA.class "amount" ] unenhanced ]

        HouseRulePackingHeat ->
            prefixed unenhanced Icon.parachuteBox

        HouseRuleReboot ->
            prefixed unenhanced Icon.random

        HouseRuleComedyWriter ->
            prefixed unenhanced Icon.pen

        HouseRuleRandoCardrissian ->
            prefixed unenhanced Icon.robot

        RereadGames ->
            [ Html.blankA [ HtmlA.class "no-wrap", HtmlA.href "https://www.rereadgames.com/" ] unenhanced ]

        MDProject ->
            [ Html.blankA [ HtmlA.class "no-wrap", HtmlA.href "https://github.com/Lattyware/massivedecks" ] unenhanced ]

        License ->
            [ Html.blankA [ HtmlA.href "https://github.com/Lattyware/massivedecks/blob/master/LICENSE" ] unenhanced ]

        TranslationBeg ->
            [ Html.blankA [ HtmlA.href "https://github.com/Lattyware/massivedecks/wiki/Translation" ] unenhanced ]

        Error ->
            prefixed unenhanced Icon.exclamationTriangle

        ErrorHelpTitle ->
            prefixed unenhanced Icon.carCrash

        ReportError ->
            prefixed unenhanced Icon.bug

        SettingsTitle ->
            prefixed unenhanced Icon.cog

        CardcastPlayCode ->
            [ Html.blankA [ HtmlA.href "https://www.cardcastgame.com/browse" ] unenhanced ]

        StillPlaying ->
            term context PlayingDescription Icon.clock unenhanced

        Played ->
            term context PlayedDescription Icon.check unenhanced

        _ ->
            unenhanced


prefixed : List (Html msg) -> Icon -> List (Html msg)
prefixed base prefix =
    Html.span [ HtmlA.class "icon-prefix" ] [ Icon.viewIcon prefix, Html.text " " ] :: base


suffixed : List (Html msg) -> Icon -> List (Html msg)
suffixed base suffix =
    base ++ [ Html.span [ HtmlA.class "icon-suffix" ] [ Html.text " ", Icon.viewIcon suffix ] ]


term : Context -> MdString -> Icon -> List (Html msg) -> List (Html msg)
term context description icon unenhanced =
    [ Html.span
        [ HtmlA.class "term", description |> asString context |> HtmlA.title ]
        [ Html.span [ HtmlA.class "full" ] unenhanced
        , Html.span [ HtmlA.class "icon-suffix" ] [ Html.text " ", Icon.viewIcon icon ]
        ]
    ]
