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
    seed: new Date().getTime().toString(), // Doesn't like int flags, change when that changes.
    browserNotificationsSupported: ("Notification" in window)
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

  game.ports.qr.subscribe(function (idAndValue) {
    new QRCode($('#' + idAndValue.id)[0], {
      text: idAndValue.value,
      width: 200,
      height: 200
    });
  });

  game.ports.requestPermission.subscribe(function (nothing) {
    Notification.requestPermission(function (permission) {
      game.ports.permissions.send(permission);
    });
  });

  game.ports.notifications.subscribe(function (notification) {
    new Notification(notification.title, {icon: notification.icon});
  });
}
