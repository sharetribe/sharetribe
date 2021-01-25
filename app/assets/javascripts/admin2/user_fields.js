function init_admin2_number_custom_field(form, locale) {
    translate_validation_messages(locale);

    var form_id = form;
    var $form = $(form_id);
    var CATEGORY_CHECKBOX_NAME = "custom_field[category_attributes][][category_id]";
    var MIN_NAME = "custom_field[min]";
    var MAX_NAME = "custom_field[max]";
    var DECIMAL_CHECKBOX = "custom_field[allow_decimals]";

    var rules = {};
    rules[CATEGORY_CHECKBOX_NAME] = {
        required: true
    };
    rules[MIN_NAME] = {
        min_bound: MAX_NAME,
        number_conditional_decimals: DECIMAL_CHECKBOX
    };
    rules[MAX_NAME] = {
        max_bound: MIN_NAME,
        number_conditional_decimals: DECIMAL_CHECKBOX
    };

    $form.validate({
        ignore: ":hidden",
        rules: rules,
        errorPlacement: function(error, element) {
            if (element.attr("name") === CATEGORY_CHECKBOX_NAME) {
                var container = $("#categories-container");
                error.insertAfter(container).addClass('form-text');
            } else {
                error.insertAfter(element).addClass('form-text');
            }
        }
    });
}

function initValidate(locale, form_id) {
    add_validator_methods();
    sortOptions();
    validateOptions();
    init_admin2_number_custom_field(form_id, locale);
    disableSelectAll();
}

$(function() {

    $(document).on('change', '#field_type', function() {
        var url = $(this).data('url'),
            value = $(this).val();
        $.get(url, {field_type: value}, null, 'script');
    });

    $('#userFieldsAddModal').on('show.bs.modal', function (e) {
        var popup = $('#userFieldsEditModal');
        if (popup.length) {
            popup.remove();
        }
        $('#body_type').html('');
        $('#field_type').val('');
    });

    if ($('#userCustomList').length) {
        Sortable.create(userCustomList, {
            handle: '.handle-move',
            animation: 250,
            onEnd: function (/**Event*/evt) {
                var array = [],
                    url = $('#userCustomList').data('url');
                $('#userCustomList > .nested').each(function( index ) {
                    array.push($(this).data('id'));
                });
                $.post(url, {order: array});
            },
        });
    }

});
