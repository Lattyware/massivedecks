module MassiveDecks.Strings.Languages.Model exposing
    ( Language(..)
    , Translator
    )

import MassiveDecks.Strings exposing (MdString)


{-| Languages. These should be IETF language tags, capitalised as-per Elm's standard.
-}
type Language
    = En
    | It
    | PtBR
    | De
    | DeXInformal
    | Pl
    | Id


{-| It makes sense to apply the language and pass around the function, so we give that a nice name.
These should only be used from views - otherwise we'll store translated text in the model, so if they change the
language it won't update.
-}
type alias Translator =
    MdString -> String
