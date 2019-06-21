module MassiveDecks.Util exposing
    ( lift
    , messageLift
    , modelLift
    )

{-| General utility methods.
-}


{-| Take a `(model, cmd)` for a specific component and turn it into a more general one.
-}
lift : (subModel -> model) -> (subMsg -> msg) -> ( subModel, Cmd subMsg ) -> ( model, Cmd msg )
lift liftModel liftMsg ( subModel, subCmd ) =
    ( liftModel subModel, subCmd |> Cmd.map liftMsg )


{-| Take a `(model, cmd)` for a specific component and turn the message into a more general one.
-}
messageLift : (subMsg -> msg) -> ( model, Cmd subMsg ) -> ( model, Cmd msg )
messageLift liftMsg ( model, subCmd ) =
    ( model, subCmd |> Cmd.map liftMsg )


{-| Take a `(model, cmd)` for a specific component and turn the model into a more general one.
-}
modelLift : (subModel -> model) -> ( subModel, Cmd msg ) -> ( model, Cmd msg )
modelLift liftModel ( subModel, cmd ) =
    ( liftModel subModel, cmd )
