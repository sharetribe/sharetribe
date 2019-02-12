window.ST = window.ST || {};
(function(module) {
  var showIntercom = function(e) {
    e.preventDefault();
    if (window.Intercom) {
      window.Intercom('show');
    }
  };

  var init = function(options) {
    $('[show-intercom]').on('click', showIntercom);
  };

  module.Domains = {
    init: init,
  };
})(window.ST);

