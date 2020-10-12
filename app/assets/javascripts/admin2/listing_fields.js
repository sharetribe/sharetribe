function sortOptions() {
    if ($('#optionsList').length) {
        Sortable.create(optionsList, {
            handle: '.handle-move',
            animation: 250,
            onEnd: function (/**Event*/evt) {
                $('.sort-options').each(function (index) {
                    $(this).val(index);
                });
            },
        });
    }
}

function validateListingFields() {
    var CATEGORY_CHECKBOX_NAME = "custom_field[category_attributes][][category_id]";

    var rules = {};

    rules[CATEGORY_CHECKBOX_NAME] = {
        required: true
    };

    $('form.listing-field-form').validate({
        rules: rules,
        errorPlacement: function(error, element) {
            if (element.attr("name") === CATEGORY_CHECKBOX_NAME) {
                var container = $("#categories-container");
                error.insertAfter(container);
            } else {
                error.insertAfter(element);
            }
        }
    });
}

function validateOptions(){
    $('form.add-new-unit-content, .edit-unit-content').validate({ ignore: ":hidden" });
}

$(function() {

    $(document).on('click', '.submit-listing-field-form', function () {
        var form = $('form.listing-field-form'),
            success = true,
            min_l = $('#minimum_length'),
            error_options = $('.error-options');
        if (min_l.length) {
            var min_length = parseInt(min_l.val());
            if ($('.options-list').length < min_length) {
                success = false;
            }
        }

        error_options.removeClass('attention').hide();

        if (form.valid() && success) {
            form.submit();
        }

        if (!success) {
           error_options.addClass('attention').show();
        }
    });

    $(document).on('change', '#field_type', function() {
        var url = $(this).data('url'),
            value = $(this).val();
        $.get(url, {field_type: value}, null, 'script');
    });

    $(document).on('click', '#new-option-trigger', function(){
        $(".add-new-unit-content").show(200);
        $("#new-option-trigger").hide(0);
        $(".remove-unit-content, .edit-unit-content").hide(0);
        return false;
    });

    $(document).on('click', "#add-new-unit-cancel", function(){
        $(".add-new-unit-content").hide(0);
        $("#new-option-trigger").show(0);
        return false;
    });

    $(document).on('click', ".remove-list-option-trigger", function(){
        $(this).parents('.options-list').find(".remove-unit-content").show(200);
        return false;
    });

    $(document).on('click', ".remove-unit-cancel", function(){
        $(this).parents('.options-list').find(".remove-unit-content").hide(0);
        return false;
    });

    $(document).on('click', ".edit-list-option-trigger", function(){
        $(this).parents('.options-list').find(".edit-unit-content").show(200);
        return false;
    });

    $(document).on('click', ".edit-unit-cancel", function(){
        $(this).parents('.options-list').find('.edit-unit-content').hide(0);
        return false;
    });

    $('#listingFieldsAddModal').on('show.bs.modal', function (e) {
        $('#body_type').html('');
        $('#field_type').val('');
    });

    $(document).on('click', '.delete-option', function () {
        var id = $(this).data('id');
        $('#custom_option_' + id).remove();
        return false;
    });

    $(document).on('click', '#save-option', function(){
        var main_div = $(this).parents('.edit-unit-content'),
            url = main_div.data('url'),
            myInputs_container = main_div.clone(),
            str = $('<form>').append(myInputs_container).serialize();
        if (main_div.find('input').valid()) {
            $.post(url, str, null, 'script');
        }
    });

    $(document).on('click', '#save-new-option', function(){
        var main_div = $(this).parents('.add-new-unit'),
            url = main_div.data('url'),
            myInputs_container = main_div.clone(),
            str = $('<form>').append(myInputs_container).serialize();
        if (main_div.find('input').valid()) {
            $.post(url, str, null, 'script');
        }
    });

    if ($('#customList').length) {
        Sortable.create(customList, {
            handle: '.handle-move',
            animation: 250,
            onEnd: function (/**Event*/evt) {
                var array = [],
                    url = $('#customList').data('url');
                $('#customList > .nested').each(function( index ) {
                    array.push($(this).data('id'));
                });
                $.post(url, {order: array});
            },
        });
    }
});
