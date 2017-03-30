# Massive Decks [![Build Status](https://travis-ci.org/Lattyware/massivedecks.svg?branch=master)](https://travis-ci.org/Lattyware/massivedecks)

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/Lattyware/massivedecks)

Massive Decks is a web game based on the excellent [Cards against Humanity][cah] - a party game where you play white cards to try and produce the most amusing outcome when combined with the given black card. The game can be played on phone or computer and uses [Cardcast decks][cardcast].

Play the game at:
**[https://massivedecks.herokuapp.com/][massivedecks]**

(This is hosted on a service that will automatically sleep if it's unused for a while - it may take a little time to load in those cases, but should be fine after the initial load.)

[![A screenshot of the game.](https://cloud.githubusercontent.com/assets/1239492/16138236/8299ee32-3433-11e6-8ca2-36993bb83d58.png)][massivedecks]

If you have any problems with the game, please [raise an issue][issue]. If you would like to help develop the game, check [the wiki][wiki] for how to get set up and help.

Massive Decks is also inspired by:
* [CardCast](https://www.cardcastgame.com/) - a great app that allows you to play on a ChromeCast.
* [Pretend You're Xyzzy](http://pretendyoure.xyz/zy/) - a web game where you can jump in with people you don't know.

This is an open source game developed in [Elm][elm] for the client and [Scala][scala] for the server.

We also use:
* [CardCast](https://www.cardcastgame.com/)'s APIs for getting decks of cards (you can go there to make your own!).
* [The Play framework](https://www.playframework.com/)
* [Less](http://lesscss.org/)
* [Font Awesome](https://fortawesome.github.io/Font-Awesome/)
* [MUI](https://www.muicss.com/)

Massive Decks is under [the AGPLv3 license][license]. The game concept 'Cards against Humanity' is used under a
[Creative Commons BY-NC-SA 2.0 license][cah-license] granted by [Cards against Humanity][cah].

[massivedecks]: https://massivedecks.herokuapp.com/
[cah]: https://cardsagainsthumanity.com/
[cardcast]: https://www.cardcastgame.com/browse
[issue]: https://github.com/Lattyware/massivedecks/issues/new
[wiki]: https://github.com/Lattyware/massivedecks/wiki
[elm]: http://elm-lang.org
[scala]: http://www.scala-lang.org/
[license]: https://github.com/Lattyware/massivedecks/blob/master/LICENSE
[cah-license]: https://creativecommons.org/licenses/by-nc-sa/2.0/
