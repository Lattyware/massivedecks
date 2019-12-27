# [Massive Decks ![Massive Decks](https://raw.githubusercontent.com/Lattyware/massivedecks/v2/client/assets/images/icon.png)][hosted]

[![Build Status](https://img.shields.io/github/workflow/status/Lattyware/massivedecks/Build%20and%20publish%20docker%20images./v2)](https://github.com/Lattyware/massivedecks/actions)
![License](https://img.shields.io/github/license/Lattyware/massivedecks)

Massive Decks is a comedy party game based on [Cards against Humanity][cah]. Play with friends! It works great with a 
bunch of people in the same room on phones, or on voice chat online.

**[Play Massive Decks][hosted]**

[hosted]: http://massivedecks.rereadgames.com/
[cah]: https://cardsagainsthumanity.com/

## About

The game is open source software available under [the AGPLv3 license][license].

The web client for the game is written in [Elm][elm], while the back-end is written in [Typescript][typescript].

[elm]: https://elm-lang.org/
[typescript]: https://www.typescriptlang.org/
[license]: https://github.com/Lattyware/massivedecks/blob/master/LICENSE

## Deploying

If you would like to run an instance of Massive Decks, there are a couple of options.

### Docker

[Server](https://hub.docker.com/repository/docker/massivedecks) / [Client](https://hub.docker.com/repository/docker/massivedecks/client/general)

Also see [`docker-compose.yml`](https://github.com/Lattyware/massivedecks/blob/v2/docker-compose.yml). The client image 
is an nginx server that both serves the static web client and acts as a proxy for the server. As such, the server should 
not be exposed publicly directly.

### Heroku

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/Lattyware/massivedecks/tree/v2) 


## Contributing

If you have any problems with the game, please [raise an issue][issue]. If you would like to help develop the game, 
check [the wiki][wiki] for how to get started.

[issue]: https://github.com/Lattyware/massivedecks/issues/new
[wiki]: https://github.com/Lattyware/massivedecks/wiki

## Credits

### Maintainers

Massive Decks is maintained by [Reread Games][reread].

[reread]: https://www.rereadgames.com/

### Inspiration

The 'Cards against Humanity' game concept is used under a [Creative Commons BY-NC-SA 2.0 license][cah-license] granted 
by [Cards against Humanity][cah].

[cah-license]: https://creativecommons.org/licenses/by-nc-sa/2.0/

Massive Decks is also inspired by:
* [CardCast][cardcast] - an app you to play on a Chromecast.
* [Pretend You're Xyzzy][xyzzy] - a web game where you can jump in with people you don't know.

[cardcast]: https://www.cardcastgame.com/
[xyzzy]: http://pretendyoure.xyz/zy/
