module MassiveDecks.Strings.Render exposing (Context, asHtml, asString)

import FontAwesome.Brands as Icon
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import Html as Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Icon as Icon
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings as Strings exposing (..)
import MassiveDecks.Strings.Languages.En.Internal as EnInternal
import MassiveDecks.Strings.Languages.Model exposing (Language)
import MassiveDecks.Strings.Translation.Model as Translation
import MassiveDecks.Util.Html as Html


type alias Context langContext =
    { lang : Language
    , translate : Maybe langContext -> MdString -> List (Translation.Result langContext)
    , parent : MdString
    , shared : Shared
    }


{-| Build an actual string from an `MdString` in the user's language.
-}
asString : Context langContext -> MdString -> String
asString context mdString =
    [ Translation.Ref Nothing mdString ] |> resultsToString context


{-| An HTML text node from the given `MdString`. Note this is more than just convenience - we enhance some strings
with rich HTML content (e.g: links, icons, etc...) when rendered as HTML.
-}
asHtml : Context langContext -> MdString -> Html Never
asHtml context mdString =
    [ Translation.Ref Nothing mdString ] |> resultsToHtml context |> Html.span []



{- Private -}


resultsToString : Context langContext -> List (Translation.Result langContext) -> String
resultsToString context results =
    results |> List.map (resultToString context) |> String.concat


resultToString : Context langContext -> Translation.Result langContext -> String
resultToString context result =
    let
        { translate, parent } =
            context

        mdStringToString langContext mdString =
            mdString |> translate langContext |> resultsToString { context | parent = mdString }

        partsToString =
            List.map (resultToString context) >> String.join ""
    in
    case result of
        Translation.Text text ->
            text

        Translation.Ref langContext mdString ->
            mdStringToString langContext mdString

        Translation.Raw langContext mdString ->
            mdStringToString langContext mdString

        Translation.Em emphasised ->
            partsToString emphasised

        Translation.Segment segment ->
            partsToString segment

        Translation.Missing ->
            EnInternal.translate Nothing parent |> partsToString


resultsToHtml : Context langContext -> List (Translation.Result langContext) -> List (Html msg)
resultsToHtml context results =
    results |> List.concatMap (resultToHtml context)


resultToHtml : Context langContext -> Translation.Result langContext -> List (Html msg)
resultToHtml context result =
    let
        { translate, parent } =
            context
    in
    case result of
        Translation.Ref langContext mdString ->
            let
                childContext =
                    { context | parent = mdString }
            in
            mdString
                |> translate langContext
                |> resultsToHtml childContext
                |> enhanceHtml childContext mdString

        Translation.Text text ->
            [ Html.text text ]

        Translation.Raw langContext mdString ->
            [ mdString |> translate langContext |> resultsToString { context | parent = mdString } |> Html.text ]

        Translation.Em emphasised ->
            [ Html.strong [] (emphasised |> resultsToHtml context) ]

        Translation.Segment cluster ->
            [ Html.span [ HtmlA.class "segment" ] (cluster |> resultsToHtml context) ]

        Translation.Missing ->
            let
                english =
                    Html.span [ HtmlA.class "string", HtmlA.lang "en" ]
                        (EnInternal.translate Nothing parent |> resultsToHtml context)

                translationBeg =
                    Html.blankA
                        [ HtmlA.href "https://github.com/Lattyware/massivedecks/wiki/Translation"
                        , Strings.TranslationBeg |> asString context |> HtmlA.title
                        ]
                        [ Icon.language |> Icon.viewIcon ]
            in
            [ Html.span [ HtmlA.class "not-translated" ] [ english, Html.text " ", translationBeg ] ]


enhanceHtml : Context langContext -> MdString -> List (Html msg) -> List (Html msg)
enhanceHtml context mdString unenhanced =
    case mdString of
        Noun { noun } ->
            case noun of
                Call ->
                    term context CallDescription Icon.callCard unenhanced

                Response ->
                    term context ResponseDescription Icon.responseCard unenhanced

                Point ->
                    term context PointDescription Icon.star unenhanced

                _ ->
                    unenhanced

        Czar ->
            term context CzarDescription Icon.gavel unenhanced

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

        HouseRuleNeverHaveIEver ->
            prefixed unenhanced Icon.trash

        HouseRuleHappyEnding ->
            prefixed unenhanced Icon.smile

        RereadGames ->
            [ Html.blankA [ HtmlA.class "no-wrap", HtmlA.href "https://www.rereadgames.com/" ] unenhanced ]

        MDProject ->
            [ Html.blankA [ HtmlA.class "no-wrap", HtmlA.href "https://github.com/Lattyware/massivedecks" ] unenhanced ]

        License ->
            [ Html.blankA [ HtmlA.href "https://github.com/Lattyware/massivedecks/blob/master/LICENSE" ] unenhanced ]

        TranslationBeg ->
            [ Html.blankA [ HtmlA.href "https://github.com/Lattyware/massivedecks/wiki/Translation" ] unenhanced ]

        TwitterHandle ->
            [ Html.blankA [ HtmlA.href "https://twitter.com/Massive_Decks" ] (suffixed unenhanced Icon.twitter) ]

        Error ->
            prefixed unenhanced Icon.exclamationTriangle

        ErrorHelpTitle ->
            prefixed unenhanced Icon.carCrash

        ReportError ->
            prefixed unenhanced Icon.bug

        SettingsTitle ->
            prefixed unenhanced Icon.cog

        StillPlaying ->
            term context PlayingDescription Icon.clock unenhanced

        Played ->
            term context PlayedDescription Icon.check unenhanced

        ManyDecks ->
            case context.shared.sources.manyDecks of
                Just { baseUrl } ->
                    [ Html.blankA [ HtmlA.href baseUrl ] unenhanced ]

                Nothing ->
                    unenhanced

        JsonAgainstHumanity ->
            case context.shared.sources.jsonAgainstHumanity of
                Just { aboutUrl } ->
                    [ Html.blankA [ HtmlA.href aboutUrl ] unenhanced ]

                Nothing ->
                    unenhanced

        _ ->
            unenhanced


prefixed : List (Html msg) -> Icon -> List (Html msg)
prefixed base prefix =
    Html.span [ HtmlA.class "icon-prefix" ] [ Icon.viewIcon prefix, Html.text " " ] :: base


suffixed : List (Html msg) -> Icon -> List (Html msg)
suffixed base suffix =
    base ++ [ Html.span [ HtmlA.class "icon-suffix" ] [ Html.text " ", Icon.viewIcon suffix ] ]


term : Context langContext -> MdString -> Icon -> List (Html msg) -> List (Html msg)
term context description icon unenhanced =
    [ Html.span
        [ HtmlA.class "term", description |> asString context |> HtmlA.title ]
        [ Html.span [ HtmlA.class "full" ] unenhanced
        , Html.span [ HtmlA.class "icon-suffix" ] [ Html.text " ", Icon.viewIcon icon ]
        ]
    ]
