window.ST = window.ST || {};

(function(module) {

  var TIMEOUT = 20000;

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
      return values.name + ' <' + values.email.toLowerCase() + '>';
    } else {
      return values.email.toLowerCase();
    }
  };

  module.initializeSenderEmailForm = function(userEmail, statusCheckUrl, resendVerificationEmailUrl) {

    var updateState = function(currentEmailState) {
      return ST.utils.baconStreamFromAjaxPolling(
        { url: statusCheckUrl,
          data: { email: currentEmailState.email }
        },
        function(pollingResult) {
          return pollingResult.updatedAt !== currentEmailState.updatedAt;
        },
        {
          timeout: TIMEOUT
        }
      );
    };

    var showLoadingSpinner = function() {
      $(".js-loaded-sender-address-status").hide();
      $(".js-status-loading").show();

      // Hide all
      [
        $(".js-status-verified"),
        $(".js-status-requested"),
        $(".js-status-error"),
        $(".js-status-expired"),
        $(".js-status-resent"),
        $(".js-sender-address-preview-new"),
        $(".js-if-you-need-to-change"),
        $(".js-sender-address-verification-sent-time-ago"),
        $(".js-sender-address-preview-current"),
        $(".js-verification-email-from")
      ].forEach(function(el) {
        el.hide();
      });
    };

    // Enqueues new email status synchronization. Returns the current
    // most up-to-date state of the email address. Returns a stream.
    var enqueueSync = function(currentState) {
      return Bacon.once({
        url: statusCheckUrl,
        data: { email: currentState.email, sync: true }
      }).ajax();
    };

    var sendNewVerificationEmail = function() {
      return Bacon.once({
        url: resendVerificationEmailUrl,
        type: "POST"
      }).ajax();
    };

    var resendVerification = function(emailState) {
      var currentEmailStateStream = Bacon.constant(emailState);

      var isExpired = function(email) {
        return email.verificationStatus === "expired";
      };

      var shouldResend = function(email) {
        return _.contains(["none", "requested", "expired"], email.verificationStatus);
      };

      var needsStatusCheckStream = currentEmailStateStream.filter(ST.utils.not(isExpired));
      var resendImmediatelyStream = currentEmailStateStream.filter(isExpired);

      var updatedStatusStream = needsStatusCheckStream
            .flatMap(function(emailState) {
              return enqueueSync(emailState);
            })
            .flatMap(function(currentState) {
              return updateState(currentState);
            });

      var shouldNotResendStream = updatedStatusStream.filter(ST.utils.not(shouldResend));
      var shouldResendStream = updatedStatusStream.filter(shouldResend);

      var resentStream = Bacon.mergeAll(resendImmediatelyStream, shouldResendStream)
        .flatMap(function(email) {
          return sendNewVerificationEmail(email).flatMap(function() {
            // Ignore the ajax response, but pass email as a stream value
            return Bacon.once(email);
          });
        });

      shouldNotResendStream.onValue(showEmailState);

      resentStream.onValue(function(email) {
        showEmailState(_.merge(email, {verificationStatus: "resent"}));
      });
      resentStream.onError(showErrorState);

      // Show loading spinner
      showLoadingSpinner();
    };

    var initializeResendHandler = function(emailState) {
      $(".js-sender-address-resend-verification").click(function(e) {
        e.preventDefault();
        resendVerification(emailState);
      });
    };

    var showEmailState = function(emailState) {
      $(".js-status-loading").hide();
      $(".js-loaded-sender-address-status").show();

      $(".js-sender-address-verification-sent-time-ago")
        .text(emailState.translatedVerificationSentTimeAgo)
        .show();

      initializeResendHandler(emailState);

      var elements = {
        "verified": [
          ".js-status-verified",
          ".js-sender-address-preview-new",
          ".js-if-you-need-to-change",
        ],
        "requested": [
          ".js-status-requested",
          ".js-sender-address-verification-sent-time-ago",
          ".js-sender-address-preview-current",
          ".js-verification-email-from",
        ],

        "expired": [
          ".js-status-expired",
          ".js-sender-address-preview-current",
        ],
        "resent": [
          ".js-status-resent",
          ".js-sender-address-preview-current",
          ".js-verification-email-from",
        ]
      };

      (elements[emailState.verificationStatus] || []).forEach(function(el) {
        $(el).show();
      });
    };

    var showErrorState = function() {
      $(".js-status-loading").hide();
      $(".js-loaded-sender-address-status").show();
      $(".js-status-error").show();
      $(".js-sender-address-preview-current").show();
    };

    var initializePreview = function() {
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
    };

    // Execute immediately

    var $form = $(".js-sender-email-form");
    $form.validate({
      rules: {
        "email": {required: true, email: true}
      }
    });

    initializePreview();

    if (userEmail && (userEmail.verificationStatus !== "verified")) {
      var stateStream = updateState(userEmail);

      stateStream.onValue(showEmailState);
      stateStream.onError(showErrorState);
    }
  };

})(window.ST);
