jQuery.extend(jQuery.validator.defaults,
    {
        errorClass: 'attention',
        errorElement: 'small',
        errorPlacement: function(error, element) {
            var hint = $(element).next('small.form-text:not(.attention)');
            if (hint.length) {
                error.insertAfter(hint).addClass('form-text');
            } else {
                error.insertAfter(element).addClass('form-text');
            }
        },
        highlight: function(element, errorClass, validClass) {
            $(element).removeClass(validClass).addClass(errorClass).next('small.attention').addClass('form-text');
        },
        unhighlight: function(element, errorClass, validClass) {
            $(element).removeClass(errorClass).addClass(validClass).next('small.attention').removeClass('form-text');
        }
    });
