window.ST = window.ST || {};
(function(module) {
  var options;

  var onChangeCanceledFlow = function(selector) {
    switch(selector) {
      case '.js-confirm-radio-button':
      $('.confirm-description, .close-listing-radio-buttons').removeClass('hidden');
      $('.cancel-description').addClass('hidden');
      $('#do_give_feedback').prop('checked', true);
      break;
      case '.js-cancel-radio-button':
      $('#do_not_give_feedback').prop('checked', true);
      $('.cancel-description').removeClass('hidden');
      $('.confirm-description, .close-listing-radio-buttons').addClass('hidden');
      break;
    }
  };

  var init = function(initOptions) {
    options = initOptions;
    ST.initializeRadioButtons({
      buttons: ['.js-confirm-radio-button', '.js-cancel-radio-button'],
      input: '.js-confirmation-status',
      callback: onChangeCanceledFlow
    });
  };

  module.ConfirmConversation = {
    init: init,
  };
})(window.ST);
