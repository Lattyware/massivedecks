module MassiveDecks.Icon exposing (..)

{-| Icons that aren't in FontAwesome that we need.
-}

import FontAwesome as Icon exposing (Icon, WithoutId)
import FontAwesome.Attributes as Icon
import FontAwesome.Solid as Icon
import MassiveDecks.Icon.Definitions as Definitions


rereadGames : Icon WithoutId
rereadGames =
    Definitions.rereadGames |> Icon.present


massiveDecks : Icon WithoutId
massiveDecks =
    Definitions.massiveDecks |> Icon.present


minimalCardSize : Icon WithoutId
minimalCardSize =
    Definitions.minimalCardSize |> Icon.present


squareCardSize : Icon WithoutId
squareCardSize =
    Definitions.squareCardSize |> Icon.present


callCard : Icon WithoutId
callCard =
    Definitions.callCard |> Icon.present


responseCard : Icon WithoutId
responseCard =
    Definitions.responseCard |> Icon.present


loading : Icon WithoutId
loading =
    Icon.circleNotch |> Icon.styled [ Icon.spin ]


manyDecks : Icon WithoutId
manyDecks =
    Definitions.manyDecks |> Icon.present


jsonAgainstHumanity : Icon WithoutId
jsonAgainstHumanity =
    Icon.code


add : Icon WithoutId
add =
    Icon.plus


remove : Icon WithoutId
remove =
    Icon.minus


new : Icon WithoutId
new =
    Icon.plus


join : Icon WithoutId
join =
    Icon.arrowRightToBracket


leave : Icon WithoutId
leave =
    Icon.arrowRightFromBracket


find : Icon WithoutId
find =
    Icon.magnifyingGlass


about : Icon WithoutId
about =
    Icon.circleQuestion


close : Icon WithoutId
close =
    Icon.xmark


start : Icon WithoutId
start =
    Icon.rocket


end : Icon WithoutId
end =
    Icon.circleStop


back : Icon WithoutId
back =
    Icon.arrowLeft


skip : Icon WithoutId
skip =
    Icon.forwardFast


configure : Icon WithoutId
configure =
    Icon.cog


show : Icon WithoutId
show =
    Icon.eye


hide : Icon WithoutId
hide =
    Icon.eyeSlash


users : Icon WithoutId
users =
    Icon.users


invite : Icon WithoutId
invite =
    Icon.bullhorn


spectator : Icon WithoutId
spectator =
    Icon.tv


player : Icon WithoutId
player =
    Icon.chessPawn


info : Icon WithoutId
info =
    Icon.info


bug : Icon WithoutId
bug =
    Icon.bug


menu : Icon WithoutId
menu =
    Icon.bars


connected : Icon WithoutId
connected =
    Icon.plugCircleCheck


disconnected : Icon WithoutId
disconnected =
    Icon.plugCircleXmark


userPromote : Icon WithoutId
userPromote =
    Icon.userPlus


userDemote : Icon WithoutId
userDemote =
    Icon.userMinus


userKick : Icon WithoutId
userKick =
    Icon.userXmark


userAway : Icon WithoutId
userAway =
    Icon.userClock


userBack : Icon WithoutId
userBack =
    Icon.userCheck


win : Icon WithoutId
win =
    Icon.trophy


toTop : Icon WithoutId
toTop =
    Icon.arrowsUpToLine


toBottom : Icon WithoutId
toBottom =
    Icon.arrowsDownToLine


help : Icon WithoutId
help =
    Icon.question


slash : Icon WithoutId
slash =
    Icon.slash


accept : Icon WithoutId
accept =
    Icon.check


discard : Icon WithoutId
discard =
    Icon.trash


history : Icon WithoutId
history =
    Icon.clockRotateLeft


random : Icon WithoutId
random =
    Icon.shuffle


czar : Icon WithoutId
czar =
    Icon.gavel


edit : Icon WithoutId
edit =
    Icon.penToSquare


undo : Icon WithoutId
undo =
    Icon.arrowRotateLeft


redo : Icon WithoutId
redo =
    Icon.arrowRotateRight


like : Icon WithoutId
like =
    Icon.thumbsUp


warning : Icon WithoutId
warning =
    Icon.triangleExclamation


left : Icon WithoutId
left =
    Icon.arrowLeft


right : Icon WithoutId
right =
    Icon.arrowRight


normalText : Icon WithoutId
normalText =
    Icon.a


italicText : Icon WithoutId
italicText =
    Icon.italic


empty : Icon WithoutId
empty =
    Icon.ghost


save : Icon WithoutId
save =
    Icon.floppyDisk


human : Icon WithoutId
human =
    Icon.user


computer : Icon WithoutId
computer =
    Icon.robot


disableAi : Icon WithoutId
disableAi =
    Icon.powerOff


disableEdit : Icon WithoutId
disableEdit =
    Icon.eraser


copy : Icon WithoutId
copy =
    Icon.copy


lock : Icon WithoutId
lock =
    Icon.lock


refresh : Icon WithoutId
refresh =
    Icon.sync


autoAdvance : Icon WithoutId
autoAdvance =
    Icon.forward


tts : Icon WithoutId
tts =
    Icon.commentDots


notification : Icon WithoutId
notification =
    Icon.bell


language : Icon WithoutId
language =
    Icon.language


point : Icon WithoutId
point =
    Icon.star


gameCode : Icon WithoutId
gameCode =
    Icon.qrcode


packingHeat : Icon WithoutId
packingHeat =
    Icon.parachuteBox


happyEnding : Icon WithoutId
happyEnding =
    Icon.smile


czarChoices : Icon WithoutId
czarChoices =
    Icon.clipboardList


waiting : Icon WithoutId
waiting =
    Icon.clock


played : Icon WithoutId
played =
    Icon.check
