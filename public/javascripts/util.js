function toggleWarningDrawer() {
  document.getElementById('warning-drawer').classList.toggle('shut');
}

function start(url, version) {
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
    version: version,
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
    } else {
      localStorage.removeItem("existing-game");
    }
  });

  if ('speechSynthesis' in window) {
    game.ports.say.subscribe(function (text) {
        window.speechSynthesis.cancel();
        var utterance = new SpeechSynthesisUtterance(text);
        utterance.lang = "en-GB";
        window.speechSynthesis.speak(utterance);
    });
  }

  game.ports.qr.subscribe(function (idAndValue) {
    new QRCode(document.getElementById(idAndValue.id), {
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
