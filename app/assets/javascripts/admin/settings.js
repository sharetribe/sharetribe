window.ST = window.ST || {};

(function(module) {

  var initializeDeleteMarketplace = function(confirmationDomain) {
    var $deleteButton = $(".js-delete-marketplace-button");
    var $confirmationForm = $(".js-delete-marketplace-confirmation-form");
    var $confirmationDomain = $(".js-delete-marketplace-confirmation-domain");

    $deleteButton.click(function() {
      $deleteButton.hide();
      $(".js-delete-marketplace-confirmation-form").show();
    });

    $confirmationForm.submit(function() {
      if($confirmationDomain.val() === confirmationDomain) {
        return true;
      } else {
        return false;
      }
    });
  };

  module.initializeDeleteMarketplace = initializeDeleteMarketplace;

})(window.ST);
