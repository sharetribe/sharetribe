jQuery.extend(jQuery.validator.defaults,
    {
        errorClass: 'attention',
        errorElement: 'small',
        errorPlacement: function(error, element) {
            var hint = $(element).next('small.form-text:not(.attention)');
            if (hint.length) {
                error.insertAfter(hint);
            } else if ($(element).parents('.input-group').length) {
                $(element).parents('.form-group').append(error)
            } else {
                error.insertAfter(element);
            }
            error.addClass('form-text');
        },
        highlight: function(element, errorClass, validClass) {
            $(element).removeClass(validClass).addClass(errorClass).next('small.attention').addClass('form-text');
        },
        unhighlight: function(element, errorClass, validClass) {
            $(element).removeClass(errorClass).addClass(validClass).next('small.attention').removeClass('form-text');
            if ($(element).parents('.multiple-languages-input').length) {
                $(element).parents('.multiple-languages-input').find('.input-group-text').removeClass('attention');
            }
        }
    });

$.validator.addMethod("regex",
    function(value, element, regexp) {
        var re = new RegExp(regexp);
        return re.test(value);
    }
);

$.validator.addMethod("allowed_template_variables", function(value, element, param) {
    var variableRegex  = /\{\{(.*?)\}\}/g,
        variables = _.map(value.match(variableRegex), function(x) { return x.replace(/[\{\}]/g, '') }),
        allowedVariables = param.split(',');
    return variables.every(function(x) { return allowedVariables.includes(x) });
});
