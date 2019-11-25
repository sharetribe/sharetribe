window.ST = window.ST || {};
(function(module) {
  var options;
  var onChange = function(selector) {
    switch(selector) {
      case '.js-confirm-radio-button':
      $('.confirm-description').removeClass('hidden');
      $('.cancel-description').addClass('hidden');
      break;
      case '.js-cancel-radio-button':
      $('.cancel-description').removeClass('hidden');
      $('.confirm-description').addClass('hidden');
      break;
    }
  };

  var onChangeCanceledFlow = function(selector) {
    switch(selector) {
      case '.js-confirm-radio-button':
      $('.confirm-description, .close-listing-radio-buttons').removeClass('hidden');
      $('.cancel-description').addClass('hidden');
      $('#do_give_feedback').prop('checked', true);
      break;
      case '.js-cancel-radio-button':
      $('.cancel-description').removeClass('hidden');
      $('.confirm-description, .close-listing-radio-buttons').addClass('hidden');
      $('#do_not_give_feedback').prop('checked', true);
      break;
    }
  };

  var init = function(initOptions) {
    options = initOptions;
    ST.initializeRadioButtons({
      buttons: ['.js-confirm-radio-button', '.js-cancel-radio-button'],
      input: '.js-confirmation-status',
      callback: (options.canceled_flow ? onChangeCanceledFlow : onChange)
    });
  };

  module.ConfirmConversation = {
    init: init,
  };
})(window.ST);
