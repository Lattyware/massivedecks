function toggleWarningDrawer() {
  document.getElementById('warning-drawer').classList.toggle('shut');
}

function getExistingGames() {
  var existingGames = localStorage.getItem("existing-games");
  try {
    existingGames = JSON.parse(existingGames);
  } catch (error) {
    existingGames = null;
  }
  if (existingGames == null) {
    existingGames = [];
  }
  return existingGames;
}

function start(url, version) {
  var initialState = {
    version: version,
    url: url,
    existingGames : getExistingGames(),
    seed: new Date().getTime().toString(), // Doesn't like int flags, change when that changes.
    browserNotificationsSupported: ("Notification" in window)
  };

  var game = Elm.MassiveDecks.fullscreen(initialState);

  game.ports.title.subscribe(function (title) {
    document.title = title;
  });

  game.ports.store.subscribe(function (existingGames) {
    localStorage.setItem("existing-games", JSON.stringify(existingGames));
  });

  if ('speechSynthesis' in window) {
    game.ports.say.subscribe(function (text) {
        window.speechSynthesis.cancel();
        var utterance = new SpeechSynthesisUtterance(text);
        // We should do something better here - other languages are likely.
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
