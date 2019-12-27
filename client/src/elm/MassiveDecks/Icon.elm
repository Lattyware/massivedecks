module MassiveDecks.Icon exposing
    ( callCard
    , massiveDecks
    , minimalCardSize
    , rereadGames
    , responseCard
    , squareCardSize
    )

{-| Icons that aren't in FontAwesome that we need.
-}

import FontAwesome.Icon exposing (Icon)


rereadGames : Icon
rereadGames =
    Icon "fab" "reread-games" 512 512 [ "M258 16c-62 0-124 24-171 71-95 94-94 246 0 339 95 93 250 93 345 0l12-12-15-14-12 12-10-10c-82 80-213 80-295 0-82-81-82-210-1-291 81-80 212-81 294-3l-38 35 129 25-1-3-26-117-39 36c-48-46-110-68-172-68zm-79 159c-46 1-70 10-70 10v133s24-9 70-9c50 0 70 20 70 20V196s-20-21-70-21zm160 0c-50 0-70 21-70 21v133s20-20 70-20c46 0 70 9 70 9V185s-24-9-70-10zM179 323c-46 1-70 10-70 10v16s24-9 70-9c50 0 81 31 81 31s30-31 80-31c46 0 70 9 70 9v-16s-24-9-70-10c-50 0-80 32-80 32s-31-32-81-32z" ]


massiveDecks : Icon
massiveDecks =
    Icon "fab" "massive-decks" 512 512 [ "M273 20c-11 0-21 9-23 21l-9 88h-8L39 163c-12 2-21 15-19 27l50 283c2 12 15 21 27 19l194-34c12-3 21-15 18-27l-13-73 140 14c13 2 25-8 26-20l30-286c1-13-8-24-21-25L276 20h-3zm0 16h1l196 21c4 0 6 3 6 7l-30 286c0 4-4 7-8 6l-144-15-35-193-3-9 10-97c1-3 4-6 7-6zm47 106l-10 99 39 4c15 2 25 0 32-8 9-8 15-21 16-37 2-15-1-29-8-39-6-9-15-13-30-15zm19 20l18 1c16 2 22 14 20 35-3 22-11 32-27 31l-18-2zm-135 91l17 98-20 4-13-77-4 80-20 3-32-73 14 76-20 4-18-98 31-6 31 75 4-81z" ]


minimalCardSize : Icon
minimalCardSize =
    Icon "fas" "minimal-card-size" 384 512 [ "M45 395c-21 0-39 17-39 39v39c0 21 18 39 39 39h294c21 0 39-18 39-39v-39c0-22-18-39-39-39z" ]


squareCardSize : Icon
squareCardSize =
    Icon "fas" "square-card-size" 384 512 [ "M45 141c-21 0-39 17-39 39v293c0 21 18 39 39 39h294c21 0 39-18 39-39V180c0-22-18-39-39-39z" ]


callCard : Icon
callCard =
    Icon "fas" "call-card" 384 512 [ "M45 10h294c16 0 29 13 29 29v434c0 16-13 29-29 29H45c-16 0-29-13-29-29V39c0-16 13-29 29-29z" ]


responseCard : Icon
responseCard =
    Icon "fas" "response-card" 384 512 [ "M45 0C24 0 6 18 6 39v434c0 21 18 39 39 39h294c21 0 39-18 39-39V39c0-21-18-39-39-39zm0 20h294c11 0 19 8 19 19v434c0 11-8 19-19 19H45c-11 0-19-8-19-19V39c0-11 8-19 19-19z" ]
