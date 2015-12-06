module MassiveDecks.Util where


interleave : List a -> List a -> List a
interleave list1 list2 =
  case list1 of
    [] ->
      list2

    x :: xs ->
      case list2 of
        [] ->
          list1

        y :: ys ->
          y :: x :: interleave xs ys

remove : List a -> Int -> List a
remove list index =
  (List.take index list) ++ (List.drop (index + 1) list)


get : List a -> Int -> a
get list index = case List.drop index list of                                                  
    [] -> Native.Error.raise <| "Attempted to take element " ++ toString index
                                ++ " of list " ++ toString list
    (item::_) -> item  


getAll : List a -> List Int -> List a
getAll list indices =
  List.map (get list) indices


getAllWithIndex : List a -> List Int -> List (Int, a)
getAllWithIndex list indices =
  getAll (List.indexedMap (,) list) indices
