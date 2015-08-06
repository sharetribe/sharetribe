window.ST = window.ST || {};

(function(module) {

  $form = $(".js-sender-email-form");
  $form.validate({
    rules: {
      "email": {required: true, email: true}
    }
  });

  var toTextStream = function(selector) {
    return $(selector)
      .asEventStream("keydown blur input change click")
      .debounce(0) // This is needed because the "keydown" event is fired before the e.target.value has the new value
      .map(function(e) { return e.target.value; })
      .skipDuplicates();
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

  module.initializeSenderEmailForm = function() {
    var $preview = $(".js-sender-address-preview-values");
    var nameStream = toTextStream(".js-sender-name-input");
    var emailStream = toTextStream(".js-sender-email-input");

    nameStream.log("Name stream value: ");
    emailStream.log("Email stream value: ");

    var nameEmailStream = Bacon.combineTemplate({
      name: nameStream.toProperty(""),
      email: emailStream.toProperty("")
    }).changes();

    nameEmailStream.onValue(function(values) {
      var text = "";
      if($form.valid()) {
        text = formatSender(values);
      } else {
        text = "-";
      }

      $preview.text(text);
    });

    nameEmailStream.log("Name and email: ");
  };

})(window.ST);
