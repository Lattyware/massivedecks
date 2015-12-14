module MassiveDecks.Util where

import Random exposing (Generator)
import String


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


get : List a -> Int -> Maybe a
get list index = case List.drop index list of
    [] -> Nothing
    (item :: _) -> Just item


getAll : List a -> List Int -> List a
getAll list indices =
  List.filterMap (get list) indices


getAllWithIndex : List a -> List Int -> List (Int, a)
getAllWithIndex list indices =
  getAll (List.indexedMap (,) list) indices


range : Int -> Int -> List Int
range first count = case count of
  0 -> []
  _ -> first :: range (first + 1) (count - 1)


inOrder : List (Generator a) -> Generator (List a)
inOrder generators = case generators of
  [] -> Random.map (\_ -> []) Random.bool
  head :: tail -> head `Random.andThen` (\value -> Random.map ((::) value) (inOrder tail))


apply : List (a -> b) -> a -> List b
apply fs value = List.map (\f -> f value) fs


firstLetterToUpper : String -> String
firstLetterToUpper str = (String.toUpper (String.left 1 str)) ++ (String.dropLeft 1 str)


mapFirst : (a -> a) -> List a -> List a
mapFirst f xs = List.indexedMap (\index x -> if index == 0 then f x else x) xs


find : (a -> Bool) -> List a -> Maybe a
find check items
  = List.filter check items
  |> List.head
