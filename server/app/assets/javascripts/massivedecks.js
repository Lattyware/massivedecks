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

function inviteOverlay(event) {
  mui.overlay('on', $('#invite')[0].cloneNode(true));
  event.preventDefault();
}

function aboutOverlay(event) {
  mui.overlay('on', $('#about')[0].cloneNode(true));
  event.preventDefault();
}
