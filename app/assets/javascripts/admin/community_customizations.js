window.ST = window.ST || {};

(function(module) {
  var initializeTransactionAgreementFields = function() {
    var checkbox = $('#community_transaction_agreement_checkbox');
    var modalFields = $('.transaction-agreement-modal');
    var checked = checkbox.is(':checked');

    modalFields
      .prop("disabled", !checked)
      .toggleClass('required', checked)
      .toggleClass('disabled', !checked);

    checkbox.click(function() {
      modalFields
        .prop("disabled", !this.checked)
        .toggleClass('required', this.checked)
        .toggleClass('disabled', !this.checked);
    });
  };

  var initializeCustomizationFormValidation = function () {
    $("#edit_community").validate({
      errorPlacement: function (error, element) {
        if (element.hasClass("selectized")) {
          element.parent().append(error);
        }
        else {
          element.after(error);
        }
      }
    });
  };

  module.initializeCommunityCustomizations = function () {
    initializeTransactionAgreementFields();
    initializeCustomizationFormValidation();
  };
})(window.ST);
