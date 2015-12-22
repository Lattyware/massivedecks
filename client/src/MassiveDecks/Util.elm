module MassiveDecks.Util

  ( interleave
  , remove
  , get
  , getAll
  , getAllWithIndex
  , range
  , inOrder
  , apply
  , firstLetterToUpper
  , mapFirst
  , find
  , isNothing
  , pluralHas
  , joinWithAnd

  ) where

import Random exposing (Generator)
import String


{-| Take two lists and inteleave them into each other. The first element will come from the second list.
-}
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


{-| Remove an element from the given list by index. If the index doesn't exist, returns the same list.
-}
remove : List a -> Int -> List a
remove list index =
  (List.take index list) ++ (List.drop (index + 1) list)


{-| Get the element at the given index, or nothing.
-}
get : List a -> Int -> Maybe a
get list index = case List.drop index list of
    [] -> Nothing
    (item :: _) -> Just item


{-| Reduce the list to the given indices.
-}
getAll : List a -> List Int -> List a
getAll list indices =
  List.filterMap (get list) indices


{-| Reduce the list to the given indices, and give those indicies with the elements.
-}
getAllWithIndex : List a -> List Int -> List (Int, a)
getAllWithIndex list indices =
  getAll (List.indexedMap (,) list) indices


{-| Get a range of numbers from the given value (inclusive) going up, with the given number of elements.
-}
range : Int -> Int -> List Int
range first count = case count of
  0 -> []
  _ -> first :: range (first + 1) (count - 1)


{-| Take a list of generators and produce a single generator producing a list, which is the result of each value applied
in order.
-}
inOrder : List (Generator a) -> Generator (List a)
inOrder generators = case generators of
  [] -> Random.map (\_ -> []) Random.bool
  head :: tail -> head `Random.andThen` (\value -> Random.map ((::) value) (inOrder tail))


{-| Apply every function in the list to the given element.
-}
apply : List (a -> b) -> a -> List b
apply fs value = List.map (\f -> f value) fs


{-| Make the first character of the string uppercase.
-}
firstLetterToUpper : String -> String
firstLetterToUpper str = (String.toUpper (String.left 1 str)) ++ (String.dropLeft 1 str)


{-| map over the first element of a list only, returning the rest as-is.
-}
mapFirst : (a -> a) -> List a -> List a
mapFirst f xs = List.indexedMap (\index x -> if index == 0 then f x else x) xs


{-| Give the first value from the list that matches the given condition. If none do, return `Nothing`.
-}
find : (a -> Bool) -> List a -> Maybe a
find check items
  = List.filter check items
  |> List.head


{-| Return `True` if the given element is `Nothing`.
-}
isNothing : Maybe a -> Bool
isNothing maybe = case maybe of
  Just _ -> False
  Nothing -> True


{-| Get "has" or "have" as appropriate for the given number of items.
-}
pluralHas : List a -> String
pluralHas items = case List.length items of
  1 -> "has"
  _ -> "have"


{-| Join the given strings together with commas and spacing, as in a list, adding an 'and' between the last two
elements.
-}
joinWithAnd : List String -> Maybe String
joinWithAnd items = case items of
  [] -> Nothing
  head :: [] -> Just head
  first :: second :: [] -> Just (first ++ " and " ++ second)
  head :: rest -> Just (head ++ ", " ++ (joinWithAnd rest |> Maybe.withDefault ""))
