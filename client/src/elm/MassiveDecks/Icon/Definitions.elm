module MassiveDecks.Icon.Definitions exposing
    ( callCard
    , manyDecks
    , massiveDecks
    , minimalCardSize
    , rereadGames
    , responseCard
    , squareCardSize
    )

{-| Icons that aren't in FontAwesome that we need.
-}

import FontAwesome exposing (IconDef)


rereadGames : IconDef
rereadGames =
    IconDef "fab" "reread-games" ( 512, 512 ) ( "M258 16c-62 0-124 24-171 71-95 94-94 246 0 339 95 93 250 93 345 0l12-12-15-14-12 12-10-10c-82 80-213 80-295 0-82-81-82-210-1-291 81-80 212-81 294-3l-38 35 129 25-1-3-26-117-39 36c-48-46-110-68-172-68zm-79 159c-46 1-70 10-70 10v133s24-9 70-9c50 0 70 20 70 20V196s-20-21-70-21zm160 0c-50 0-70 21-70 21v133s20-20 70-20c46 0 70 9 70 9V185s-24-9-70-10zM179 323c-46 1-70 10-70 10v16s24-9 70-9c50 0 81 31 81 31s30-31 80-31c46 0 70 9 70 9v-16s-24-9-70-10c-50 0-80 32-80 32s-31-32-81-32z", Nothing )


massiveDecks : IconDef
massiveDecks =
    IconDef "fab" "massive-decks" ( 512, 512 ) ( "M273 20c-11 0-21 9-23 21l-9 88h-8L39 163c-12 2-21 15-19 27l50 283c2 12 15 21 27 19l194-34c12-3 21-15 18-27l-13-73 140 14c13 2 25-8 26-20l30-286c1-13-8-24-21-25L276 20h-3zm0 16h1l196 21c4 0 6 3 6 7l-30 286c0 4-4 7-8 6l-144-15-35-193-3-9 10-97c1-3 4-6 7-6zm47 106l-10 99 39 4c15 2 25 0 32-8 9-8 15-21 16-37 2-15-1-29-8-39-6-9-15-13-30-15zm19 20l18 1c16 2 22 14 20 35-3 22-11 32-27 31l-18-2zm-135 91l17 98-20 4-13-77-4 80-20 3-32-73 14 76-20 4-18-98 31-6 31 75 4-81z", Nothing )


minimalCardSize : IconDef
minimalCardSize =
    IconDef "fas" "minimal-card-size" ( 384, 512 ) ( "M45 395c-21 0-39 17-39 39v39c0 21 18 39 39 39h294c21 0 39-18 39-39v-39c0-22-18-39-39-39z", Nothing )


squareCardSize : IconDef
squareCardSize =
    IconDef "fas" "square-card-size" ( 384, 512 ) ( "M45 141c-21 0-39 17-39 39v293c0 21 18 39 39 39h294c21 0 39-18 39-39V180c0-22-18-39-39-39z", Nothing )


callCard : IconDef
callCard =
    IconDef "fas" "call-card" ( 384, 512 ) ( "M45 10h294c16 0 29 13 29 29v434c0 16-13 29-29 29H45c-16 0-29-13-29-29V39c0-16 13-29 29-29z", Nothing )


responseCard : IconDef
responseCard =
    IconDef "fas" "response-card" ( 384, 512 ) ( "M45 0C24 0 6 18 6 39v434c0 21 18 39 39 39h294c21 0 39-18 39-39V39c0-21-18-39-39-39zm0 20h294c11 0 19 8 19 19v434c0 11-8 19-19 19H45c-11 0-19-8-19-19V39c0-11 8-19 19-19z", Nothing )


manyDecks : IconDef
manyDecks =
    IconDef "fab" "massive-decks" ( 512, 512 ) ( "M248 0c-4 0-8 4-9 9l-4 37h-3l-82 15c-5 1-8 6-8 11l21 121c1 5 7 9 12 8l81-14c5-2 9-7 7-12l-5-31 59 6c5 1 10-3 11-9l12-121c1-6-3-11-9-11l-81-9zm0 7h1l82 9c2 0 2 1 2 3l-12 122c0 1-2 3-3 2l-61-6-14-82-2-4 4-42 3-2zm20 45-4 42 16 2c7 1 11 0 14-4 3-3 6-8 6-15 1-7 0-13-3-17s-6-5-13-6zm8 9h8c6 1 9 6 8 15s-5 13-11 13l-8-1zm-57 38 8 42-9 2-5-33-2 34-8 1-14-31 6 33-8 1-8-41 13-3 13 32 2-35zm120 238c-13 0-26-7-33-18l-50-84-50 84a38 38 0 0 1-43 17L56 305v139c0 12 8 22 19 24l169 43c8 2 16 2 24 0l169-43c12-2 19-12 19-24V305l-107 30c-3 2-7 2-10 2zm166-88-40-80c-2-5-8-8-13-7l-196 25 72 119c3 5 9 7 14 6l155-45c8-2 12-10 8-18zM47 169 7 249c-4 7 0 16 8 18l155 45c5 1 11-1 14-6l72-119-196-25c-5-1-10 2-13 7z", Nothing )
