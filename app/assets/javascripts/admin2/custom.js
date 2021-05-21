function getKeysForValue(obj, value) {
  var all;
  $.each(obj, function(key, val){
    if(val === value){
      all = key;
      return false;
    }
  });
  return all;
}

function showError(text) {
    if ($('.ajax-update-notification').length) {
        $('.ajax-update-notification').remove();
    }
    $('.topnav').after('<div class="alert alert-danger ajax-update-notification" role="alert"><button class="close" data-dismiss="alert">x</button>'+ text +'</div>');
}

function showSuccess(text) {
    if ($('.ajax-update-notification').length) {
        $('.ajax-update-notification').remove();
    }
    $('.topnav').after('<div class="alert alert-info ajax-update-notification" role="alert"><button class="close" data-dismiss="alert">x</button>'+ text +'</div>');
}

function validateCommunityEdit(community_id) {
    $("#edit_community_" + community_id).validate({
        rules: {
            "community[automatic_confirmation_after_days]": {max: 85}
        },
        errorPlacement: function (error, element) {
            var hint = $(element).next('small.form-text:not(.attention)');
            if (element.attr('id') === 'community_automatic_confirmation_after_days') {
                $(element).parents('.form-group').append(error);
            } else if (element.hasClass('social-link-row')) {
                element.parents('.one-social-link').find('.handle-move').after(error);
            } else if (hint.length) {
                error.insertAfter(hint);
            }
            else {
                element.after(error);
            }
            error.addClass('form-text');
        },
        onkeyup: false,
        onclick: false,
        onfocusout: false,
        onsubmit: true
    });
}

function admin2_social_media_form(community_id, invalid_twitter_handle_message, invalid_facebook_connect_id_message, invalid_facebook_connect_secret_message) {
    var form_id = "#edit_community_" + community_id;
    $(form_id).validate({
        rules: {
            "community[twitter_handle]": {minlength: 1, maxlength: 15, regex: "^([A-Za-z0-9_]+)?$"},
            "community[facebook_connect_id]": {minlength: 1, maxlength: 16, regex: "^([0-9]+)?$"},
            "community[facebook_connect_secret]": {minlength: 32, maxlength: 32, regex: "^([a-f0-9]+)?$"}
        },
        messages: {
            "community[twitter_handle]": { regex: invalid_twitter_handle_message },
            "community[facebook_connect_id]": {regex: invalid_facebook_connect_id_message },
            "community[facebook_connect_secret]": {regex: invalid_facebook_connect_secret_message }
        }
    });
}

function validateCustomForm() {
    $('form').validate({
        onkeyup: false,
        onclick: false,
        onfocusout: false,
        onsubmit: true
    });
}

function showIntercom(e) {
    e.preventDefault();
    if (window.Intercom) {
        window.Intercom('show');
    }
}

function initIntercom(){
  $('[show-intercom]').on('click', showIntercom);
}

function disableSelectAll() {
    var btn_select = $('.select-all-checkbox');
    if (btn_select.length) {
        btn_select.each(function() {
            var btn_select_all = $(this),
                btn_unselect_all = $(this).closest('.form-group').find('.unselect-all-checkbox');
            var total_checkbox = btn_select_all.closest('.form-group').find('input[type=checkbox]').length,
                selected_checkbox = btn_select_all.closest('.form-group').find('input[type=checkbox]:checked').length;
            if (total_checkbox === selected_checkbox) {
                btn_select_all.prop('disabled', true);
                btn_select_all.addClass('disabled');
                btn_unselect_all.prop('disabled', false);
                btn_unselect_all.removeClass('disabled');
            } else {
                btn_select_all.prop('disabled', false);
                btn_select_all.removeClass('disabled');
            }
            if (!selected_checkbox) {
                btn_unselect_all.prop('disabled', true);
                btn_unselect_all.addClass('disabled');
            } else {
                btn_unselect_all.prop('disabled', false);
                btn_unselect_all.removeClass('disabled');
            }
        });
    }
}

$(function(){

    $('#video').on('hidden.bs.modal', function () {
      $("#video iframe").attr("src", $("#video iframe").attr("src"));
    });

    $(document).on('change', '.with-select-all', function () {
      disableSelectAll();
    });

    $(document).on('click', '.select-all-checkbox', function () {
        $(this).closest('.form-group').find('input[type=checkbox]').prop('checked', true);
        disableSelectAll();
        return false;
    });

    $(document).on('click', '.unselect-all-checkbox', function () {
        $(this).closest('.form-group').find('input[type=checkbox]').prop('checked', false);
        disableSelectAll();
        return false;
    });

    $('.country-currency').on('change', function() {
        var url = $(this).data('url'),
            currency = $(this).val();
        $.get(url, {currency: currency});
    });

    $('.location-type').on('change', function() {
       var value = $(this).val(),
           show_distance_div = $('.show-distance-div'),
           show_distance = $('.show-distance');

        if (value === 'keyword') {
            show_distance.prop('disabled', true);
            show_distance_div.addClass('opacity_035');
        } else {
            show_distance.prop('disabled', false);
            show_distance_div.removeClass('opacity_035');
        }
    });

    if ($('#simpleList').length) {
        Sortable.create(simpleList, {
            handle: '.handle-move',
            animation: 250,
            onEnd: function (/**Event*/evt) {
                $('.top_bar_link_position').each(function( index ) {
                    $(this).find('.sort_priority_class').val(index);
                });
                $('#simpleList').closest('form').find('button').prop('disabled', false);
            }
        });
        $('#top_bar_div, #footer_div').on('cocoon:after-insert', function(e, insertedItem, originalEvent) {
            var index = $('.top_bar_link_position').length - 1;
            insertedItem.find('.sort_priority_class').val(index);
        });
        $('#top_bar_div, #footer_div').on('cocoon:after-remove', function(e, insertedItem, originalEvent) {
            $('#simpleList').closest('form').find('button').prop('disabled', false);
        });
    }

    if ($('#footerList').length) {
        Sortable.create(footerList, {
            handle: '.handle-move',
            animation: 250,
            onEnd: function (/**Event*/evt) {
                $('.one-social-link').each(function( index ) {
                    $(this).find('.social-link-sort-prior').val(index);
                });
                $('#footerList').closest('form').find('button').prop('disabled', false);
            },
        });
    }

    $('.for-hide-content').on('change', function () {
       var checked = $(this).prop('checked'),
           private_content = $('.hide-content'),
           hidden_required = $(this).hasClass('hidden-required');
       if (checked) {
           private_content.removeClass('opacity_035');
           if (hidden_required) {
               private_content.find('input, textarea').addClass('required');
           }
       } else {
           private_content.addClass('opacity_035');
           if (hidden_required) {
               private_content.find('input, textarea').removeClass('required');
           }
       }
    });
    $('.social-checked').on('change', function () {
       var input_elem = $(this).parents('.social-block').find('.social-data');
       if ($(this).prop('checked')) {
           input_elem.addClass('required');
       } else {
           input_elem.removeClass('required');
       }
    });
    $('.change-file').on('change', function() {
       var place = $(this).parents('.custom-file').find('.choose-filename');
       place.hide();
    });

});
