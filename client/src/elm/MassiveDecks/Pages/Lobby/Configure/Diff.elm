module MassiveDecks.Pages.Lobby.Configure.Diff exposing
    ( MergeResult
    , merge
    )

{-| The updated configuration after the merge, with any conflicting components.
-}

import MassiveDecks.Pages.Lobby.Configure.Configurable.Model as Configurable exposing (Component)


type alias MergeResult config id =
    { updated : config
    , conflicts : List id
    }


type alias InternalMergeResult config id =
    { updated : config
    , conflicts : List id
    , all : Bool
    }


{-| Merge the configurations in a three way merge.
-}
merge : Component id config model msg -> config -> config -> config -> config -> MergeResult config id
merge component base local remote update =
    let
        { updated, conflicts } =
            internalMerge component base local remote update
    in
    MergeResult updated conflicts



{- Private -}


internalMerge : Component id config model msg -> config -> config -> config -> config -> InternalMergeResult config id
internalMerge component base local remote update =
    case component of
        Configurable.C c ->
            if c.children |> List.isEmpty then
                let
                    set =
                        c.setTarget c.id
                in
                case threeWay c.equals base local remote of
                    NoChange ->
                        { updated = update, conflicts = [], all = False }

                    RemoteChange ->
                        { updated = update |> set remote, conflicts = [], all = False }

                    LocalChange ->
                        { updated = update |> set local, conflicts = [], all = False }

                    ConflictingChanges ->
                        { updated = update |> set local, conflicts = [ c.id ], all = True }

                    AgreedChange ->
                        { updated = update |> set remote, conflicts = [], all = False }

            else
                let
                    result =
                        c.children
                            |> List.foldl (mergeFold base local remote)
                                { updated = update, conflicts = [], all = True }
                in
                if result.all then
                    { updated = result.updated, conflicts = [ c.id ], all = True }

                else
                    result


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


mergeFold : config -> config -> config -> Component id config model msg -> InternalMergeResult config id -> InternalMergeResult config id
mergeFold base local remote c previously =
    let
        { updated, conflicts, all } =
            internalMerge c base local remote previously.updated
    in
    { updated = updated, conflicts = previously.conflicts ++ conflicts, all = previously.all && all }
