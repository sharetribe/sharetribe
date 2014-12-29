window.ST = window.ST || {};

(function(module) {
  module.initializeExpirationNotice = function(expirationNoticeId) {
    $('#'+expirationNoticeId).lightbox_me({modalCSS: {top: '5px'}, zIndex: 1000000, closeEsc: false, closeClick: false});
  };
})(window.ST);