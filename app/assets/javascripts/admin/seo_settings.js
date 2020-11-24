window.ST = window.ST || {};
(function(module) {
  var init = function(options) {
    $.validator.addMethod("allowed_template_variables", function(value, element, param) {
      var variableRegex  = /\{\{(.*?)\}\}/g,
        variables = _.map(value.match(variableRegex), function(x) { return x.replace(/[\{\}]/g, '') }),
        allowedVariables = param.split(',');
      return variables.every(function(x) { return allowedVariables.includes(x) });
    });
    $('form.edit_community').validate();
  };

  module.SeoSettings = {
    init: init,
  };
})(window.ST);

