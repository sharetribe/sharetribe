window.ST = window.ST || {};

(function(module) {
  module.listing = function() {
    $('#add-to-updates-email').on('click', function() {
      var text = $(this).find('#add-to-updates-email-text');
      var actionLoading = text.data('action-loading');
      var actionSuccess = text.data('action-success');
      var actionError = text.data('action-error');
      var url = $(this).attr('href');

      text.html(actionLoading);

      $.ajax({
        url: url,
        type: "PUT",
      }).done(function() {
        text.html(actionSuccess);
      }).fail(function() {
        text.html(actionError);
      });
    });
  };

  module.initializeQuantityValidation = function(opts) {
    jQuery.validator.addMethod(
      "positiveIntegers",
      function(value) {
        return (value % 1) === 0 && value > 0;
      },
      jQuery.validator.format(opts.errorMessage)
    );

    // add rule to input
    $('#'+opts.input).rules("add", {
      positiveIntegers: true
    });
  };

})(window.ST);
