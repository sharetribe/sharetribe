window.ST = window.ST || {};

(function(module) {

  var $form = $(".js-sender-email-form");
  $form.validate({
    rules: {
      "email": {required: true, email: true}
    }
  });

  var toTextStream = function(selector) {
    return $(selector)
      .asEventStream("keydown blur input change click")
      .debounce(0) // This is needed because the "keydown" event is fired before the e.target.value has the new value
      .map(function(e) { return e.target.value; });
  };

  var formatSender = function(values) {
    if(!values.email) {
      return "-";
    } else if(values.name) {
      return values.name + ' <' + values.email + '>';
    } else {
      return values.email;
    }
  };

  module.initializeSenderEmailForm = function(userEmail, statusCheckUrl) {
    var $previewContainer = $(".js-sender-address-preview-container");
    var $preview = $(".js-sender-address-preview-values");
    var nameStream = toTextStream(".js-sender-name-input");
    var emailStream = toTextStream(".js-sender-email-input");
    var validEmailOrEmptyStream = emailStream.map(function(v) {
      return $form.valid() ? v : "";
    });

    var nameEmailStream = Bacon
          .combineTemplate({
            name: nameStream.toProperty(""),
            email: validEmailOrEmptyStream.toProperty("")
          })
          .skipDuplicates(_.isEqual)
          .changes();

    var validEmailStream = emailStream.filter(function() { return $form.valid(); });
    validEmailStream.take(1).onValue(function() {
      $previewContainer.show();
    });

    nameEmailStream.onValue(function(values) {
      $preview.text(formatSender(values));
    });

    if (userEmail && (userEmail.verificationStatus === "none" || userEmail.verificationStatus === "requested")) {
      var pollingStream = ST.utils.baconStreamFromAjaxPolling(
        { url: statusCheckUrl,
          data: { email: userEmail.email }
        },
        function(pollingResult) {
          return pollingResult.updatedAt !== userEmail.updatedAt;
        },
        {
          timeout: 10000
        }
      );

      pollingStream.onValue(function(result) {
        $(".js-status-loading").hide();
        $(".js-loaded-sender-address-status").show();
        $(".js-status-" + result.verificationStatus).show();

        if(result.verificationStatus === "verified") {
          $(".js-sender-address-preview-new").show();
          $(".js-if-you-need-to-change").show();
        } else {
          $(".js-sender-address-preview-current").show();
        }
      });
      pollingStream.onError(function() {
        $(".js-status-loading").hide();
        $(".js-loaded-sender-address-status").show();
        $(".js-status-error").show();
        $(".js-sender-address-preview-current").show();
      });
    }
  };

})(window.ST);
