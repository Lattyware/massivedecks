module MassiveDecks.Util exposing
    ( batchUpdate
    , modelLift
    )

{-| General utility methods.
-}


{-| Take a `(model, cmd)` for a specific component and turn the model into a more general one.
-}
modelLift : (subModel -> model) -> ( subModel, Cmd msg ) -> ( model, Cmd msg )
modelLift liftModel ( subModel, cmd ) =
    ( liftModel subModel, cmd )


{-| Perform the given update task for each of the messages in a row.
-}
batchUpdate : List msg -> model -> (msg -> model -> ( model, Cmd cmdMsg )) -> ( model, Cmd cmdMsg )
batchUpdate messages model update =
    let
        ( newModel, cmdList ) =
            messages |> List.foldl (batchUpdateStep update) ( model, [] )
    in
    ( newModel, cmdList |> List.reverse |> Cmd.batch )



{- Private -}


batchUpdateStep : (msg -> model -> ( model, Cmd cmdMsg )) -> msg -> ( model, List (Cmd cmdMsg) ) -> ( model, List (Cmd cmdMsg) )
batchUpdateStep update msg ( model, cmdList ) =
    let
        ( newModel, newCmd ) =
            update msg model
    in
    ( newModel, newCmd :: cmdList )
