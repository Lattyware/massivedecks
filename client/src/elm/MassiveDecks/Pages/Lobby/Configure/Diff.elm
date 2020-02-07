module MassiveDecks.Pages.Lobby.Configure.Diff exposing
    ( MergeResult
    , merge
    )

import MassiveDecks.Pages.Lobby.Configure.Component as Component exposing (Component)


{-| The updated configuration after the merge, with any conflicting components.
-}
type alias MergeResult config id =
    { updated : config
    , conflicts : List id
    }


{-| Merge the configurations in a three way merge.
-}
merge : Component config model id iMsg msg -> config -> config -> config -> config -> MergeResult config id
merge component base local remote update =
    case component of
        Component.V v ->
            case threeWay v.equal base local remote of
                NoChange ->
                    { updated = update, conflicts = [] }

                RemoteChange ->
                    { updated = update |> v.update remote, conflicts = [] }

                LocalChange ->
                    { updated = update |> v.update local, conflicts = [] }

                ConflictingChanges ->
                    { updated = update |> v.update local, conflicts = [ v.id ] }

                AgreedChange ->
                    { updated = update |> v.update remote, conflicts = [] }

        Component.G { children } ->
            children |> List.foldl (mergeFold base local remote) { updated = update, conflicts = [] }



{- Private -}


{-| The result of doing a three-way diff over a value.
-}
type ThreeWayResult value
    = NoChange
    | RemoteChange
    | LocalChange
    | AgreedChange
    | ConflictingChanges


{-| Do a three way diff and find out what happened.
-}
threeWay : (value -> value -> Bool) -> value -> value -> value -> ThreeWayResult value
threeWay eq base local remote =
    if eq base local then
        if eq base remote then
            NoChange

        else
            RemoteChange

    else if eq base remote then
        LocalChange

    else if eq local remote then
        AgreedChange

    else
        ConflictingChanges


mergeFold : config -> config -> config -> Component config model id iMsg msg -> MergeResult config id -> MergeResult config id
mergeFold base local remote c previously =
    let
        { updated, conflicts } =
            merge c base local remote previously.updated
    in
    { updated = updated, conflicts = previously.conflicts ++ conflicts }
