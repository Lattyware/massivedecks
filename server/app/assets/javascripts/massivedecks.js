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

function toggleWarningDrawer() {
  $('#warning-drawer').toggleClass('shut');
}

function start(url) {
  var socket = null;
  var gameCode = window.location.hash.substr(1);
  var existingGame = localStorage.getItem("existingGame");
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
    seed: new Date().getTime()
  };

  var game = Elm.fullscreen(Elm.MassiveDecks.Main, { notifications: "", initialState: initialState });

  game.ports.initialState.send(initialState);

  function openWebSocket(lobbyId, secret) {
    var loc = window.location, new_uri;
    if (loc.protocol === "https:") {
      new_uri = "wss:";
    } else {
      new_uri = "ws:";
    }
    new_uri += "//" + loc.host;
    new_uri += loc.pathname + "lobbies/" + lobbyId + "/notifications";
    if (socket != null) {
      socket.close();
    }
    socket = new WebSocket(new_uri);
    socket.onopen = function (event) {
      socket.send(JSON.stringify(secret));
    }
    socket.onmessage = function (event) {
      game.ports.notifications.send(event.data);
    }
    socket.onclose = function (event) {
      if (socket != null) {
        openWebSocket(lobbyId, secret);
      }
    }
  }

  game.ports.subscription.subscribe(function (lobbyIdAndSecret) {
    if (lobbyIdAndSecret != null) {
      localStorage.setItem("existingGame", JSON.stringify(lobbyIdAndSecret))
      openWebSocket(lobbyIdAndSecret.lobbyId, lobbyIdAndSecret.secret);
      window.location = "#" + lobbyIdAndSecret.lobbyId;
    } else {
      if (socket != null) {
        window.location = "#";
        localStorage.removeItem("existingGame");
        var oldSocket = socket;
        socket = null;
        oldSocket.close();
      }
    }
  });
}
