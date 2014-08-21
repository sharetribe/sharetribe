window.ST = window.ST || {};

(function(module) {

  module.initializeTransactionAgreementFields = function() {
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

    $('#edit_community').validate();
  };
})(window.ST);
