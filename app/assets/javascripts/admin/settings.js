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

  function checkLocationMode() {
    var mode = $("#main_search").val();
    if (mode && mode.match(/location/)) {
      $('.if-location-enabled').show();
    } else {
      $('.if-location-enabled').hide();
    }
    var show_loc = $("#community_show_location")[0].checked;
    if (show_loc) {
      $("#main_search option").prop("disabled", false);
    } else {
      $("#main_search option:not(:first)").prop("disabled", true);
      if (mode != "keyword") {
        $("#main_search").val("keyword").trigger("change");
      }
    }
  }

  var initializeLocationSearchModeSwitch = function() {
    $("#main_search").change(checkLocationMode);
    $("#community_show_location").click(checkLocationMode);
    checkLocationMode();
  };

  module.initializeDeleteMarketplace = initializeDeleteMarketplace;
  module.initializeLocationSearchModeSwitch = initializeLocationSearchModeSwitch;

})(window.ST);
