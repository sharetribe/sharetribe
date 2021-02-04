jQuery.extend(jQuery.validator.defaults,
    {
        errorClass: 'attention',
        errorElement: 'small',
        errorPlacement: function(error, element) {
            var hint = $(element).next('small.form-text:not(.attention)');
            if (hint.length) {
                error.insertAfter(hint);
            } else if ($(element).parents('.input-group').length && $(element).parents('.form-group').length) {
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

$.validator.addMethod("valid_listing",
    function(value, element, param) {
       var url = $(element).data('url'),
           id = $(element).val(),
           result = false;

        $.ajax({
            url : url,
            data: { id: id },
            type : 'get',
            async : false,
            success : function(data) {
                result = data['listing_exist'];
            }
        });

        return result;
    }
);

$.validator.addMethod('count-validation', function(value, element, params) {
    var name = $(element).data("counter-name");
    var count = $(".edit-dropdown-list-option-trigger:visible").size();
    var min = $(element).data("min");
    var max = $(element).data("max");
    if (max) {
        return count <= max;
    } else {
        return count >= min;
    }
});

$.validator.addMethod("allowed_template_variables", function(value, element, param) {
    var variableRegex  = /\{\{(.*?)\}\}/g,
        variables = _.map(value.match(variableRegex), function(x) { return x.replace(/[\{\}]/g, '') }),
        allowedVariables = param.split(',');
    return variables.every(function(x) { return allowedVariables.includes(x) });
});
