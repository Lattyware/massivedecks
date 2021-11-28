# [Massive Decks ![Massive Decks](https://raw.githubusercontent.com/Lattyware/massivedecks/main/client/assets/images/icon.png)][hosted]

[![Current Release Version](https://img.shields.io/github/v/tag/Lattyware/massivedecks?label=release&sort=semver)](https://github.com/Lattyware/massivedecks/releases)
[![Build Status](https://img.shields.io/github/workflow/status/Lattyware/massivedecks/Build)](https://github.com/Lattyware/massivedecks/actions)
[![License](https://img.shields.io/github/license/Lattyware/massivedecks)](LICENSE)
[![Follow on Twitter for Status & Updates](https://img.shields.io/twitter/follow/Massive_Decks?label=Status%20%26%20Updates&style=social)][twitter]

Massive Decks is a free, open source comedy party game based on [Cards against Humanity][cah]. Play with friends!

**[Play Massive Decks][hosted]**

[hosted]: https://md.rereadgames.com/
[cah]: https://cardsagainsthumanity.com/
[twitter]: https://twitter.com/Massive_Decks

## Features

- Play together in the same room or online.
- Use any device (Phone, PC, Chromecast, anything with a web browser).
- You can set up a central screen, but you don't need to (no need to stream anything for other players online).
- Custom decks (via [Many Decks][many-decks]).
- Customise the rules:
  - Custom cards.
  - House rules.
  - AI players.
  - Custom time limits if you want them.
- Spectators.
- Keeps your game private by default, you can also set a game password if needed.
- Community translations.

[many-decks]: https://decks.rereadgames.com/

## About

The game is open source software available under [the AGPLv3 license](LICENSE).

The web client for the game is written in [Elm][elm], while the back-end is written in [Typescript][typescript].

[elm]: https://elm-lang.org/
[typescript]: https://www.typescriptlang.org/

## Deploying

If you would like to run a production instance of Massive Decks, there are a couple of options.

It is suggested you read the [deployment guide on the wiki][deployment-guide].

[deployment-guide]: https://github.com/Lattyware/massivedecks/wiki/Deploying

### Docker

The Docker images can be found on the GitHub Container Registry:
[Server](https://github.com/users/Lattyware/packages/container/package/massivedecks%2Fserver) /
[Client](https://github.com/users/Lattyware/packages/container/package/massivedecks%2Fclient).

There are example docker deployments in [the deployment folder](deployment).

### Heroku

You can deploy to Heroku with the button below:

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/Lattyware/massivedecks)

If you want to customise the deployment further, you can deploy through heroku from your own fork of the project with
modification (note the button above is hard-coded to this repository).

## Contributing

If you have any problems with the game, please [raise an issue][issue]. If you would like to help develop the game,
check [the wiki's contribution guide][contributing] for how to get started.

The game has a system for translation, and if you would like to provide translation to a new language, please see
[the guide on the wiki][translation].

[issue]: https://github.com/Lattyware/massivedecks/issues/new
[contributing]: https://github.com/Lattyware/massivedecks/wiki/Contributing
[translation]: https://github.com/Lattyware/massivedecks/wiki/Translation

## Credits

### Contributors

Massive Decks is open source, and would not be possible without the time and work of
[the community members][github-contributors] who have contributed code and localizations.

[github-contributors]: https://github.com/Lattyware/massivedecks/graphs/contributors

### Maintainers

[Reread Games][reread] maintains Massive Decks. If you enjoy Massive Decks, please take a look at their other games.

[reread]: https://www.rereadgames.com/

### Inspiration

The 'Cards against Humanity' game concept is used under a [Creative Commons BY-NC-SA 2.0 license][cah-license] granted
by [Cards against Humanity][cah].

[cah-license]: https://creativecommons.org/licenses/by-nc-sa/2.0/

Massive Decks is also inspired by:

- [CardCast][cardcast] - an app that allowed you to play on a Chromecast, now dead.
- [Pretend You're Xyzzy][xyzzy] - another web implementation.

[cardcast]: https://www.cardcastgame.com/
[xyzzy]: http://pretendyoure.xyz/zy/
