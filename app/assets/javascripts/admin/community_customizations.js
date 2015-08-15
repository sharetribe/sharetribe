window.ST = window.ST || {};

(function(module) {

  var initializeTransactionAgreementFields = function() {
    $('#community_transaction_agreement_checkbox').click(updateFieldModality);
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

  var updateFieldStatus = function($field, enabled) {
    $field
      .prop('disabled', !enabled)
      .toggleClass('disabled', !enabled)
      .toggleClass('required', enabled);
  };

  var updateFieldModality = function() {
    var txAgreementEnabled = $('#community_transaction_agreement_checkbox').is(':checked');
    var modalFields = $('input.transaction-agreement-modal, textarea.transaction-agreement-modal');
    
    updateFieldStatus(modalFields, false);

    if (txAgreementEnabled) {
      modalFields.filter(function(){
        return $(this).data("locale-enabled") === true;
      }).each(function(index, field){
        updateFieldStatus($(field), true);
      });
    }
  };

  module.updateLocales = function(locales) {
    var modalFields = $('input.transaction-agreement-modal, textarea.transaction-agreement-modal');
    modalFields.data("locale-enabled", false);
    $(locales).each(function(index, locale){
      modalFields.filter("[name*='["+locale+"]']").data("locale-enabled", true);
    });
    updateFieldModality();
  };

  module.initializeCommunityCustomizations = function () {
    initializeTransactionAgreementFields();
    initializeCustomizationFormValidation();
  };
})(window.ST);
