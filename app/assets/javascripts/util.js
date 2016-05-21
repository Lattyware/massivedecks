jQuery(function($) {
  var $bodyEl = $('body');

  function showScores() {
    var scores = $('#scores')[0].cloneNode(true);

    mui.overlay('on', scores);

    setTimeout(function() {
      $(scores).addClass('active');
    }, 20);
  }

  function hideScores() {
    $bodyEl.toggleClass('hide-scores');
  }

  $('body').on('click', '.js-show-scores', showScores);
  $('body').on('click', '.js-hide-scores', hideScores);
});

function inviteOverlay() {
  mui.overlay('on', $('#invite')[0].cloneNode(true));
}

function aboutOverlay() {
  mui.overlay('on', $('#about')[0].cloneNode(true));
}

function closeOverlay() {
  mui.overlay('off');
}

function toggleWarningDrawer() {
  $('#warning-drawer').toggleClass('shut');
}

function start(url) {
  var gameCode = window.location.hash.substr(1);
  var existingGame = localStorage.getItem("existing-game");
  if (existingGame != null) {
    try {
      existingGame = JSON.parse(existingGame);
    } catch (error) {
      existingGame = null;
    }
  }
  var initialState = {
    url: url,
    gameCode: gameCode == "" ? null : gameCode,
    existingGame: existingGame,
    seed: new Date().getTime().toString() // Doesn't like int flags, change when that changes.
  };

  var game = Elm.MassiveDecks.fullscreen(initialState);

  game.ports.existingGame.subscribe(function (gameCodeAndSecret) {
    if (gameCodeAndSecret != null) {
      localStorage.setItem("existing-game", JSON.stringify(gameCodeAndSecret))
      window.location = "#" + gameCodeAndSecret.gameCode;
    } else {
      window.location = "#";
      localStorage.removeItem("existing-game");
    }
  });
}
