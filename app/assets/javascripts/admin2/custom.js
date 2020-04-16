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
        errorPlacement: function (error, element) {
            if (element.attr('id') === 'community_automatic_confirmation_after_days') {
                $('#days_label').after(error);
            } else if (element.hasClass('social-link-row')) {
                element.parents('.one-social-link').find('.handle-move').after(error);
            }
            else {
                element.after(error);
            }
        },
        onkeyup: false,
        onclick: false,
        onfocusout: false,
        onsubmit: true
    });
}

function validateCustomForm() {
    $('form').validate({
        errorPlacement: function (error, element) {
           element.after(error);
        },
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

$(function(){
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
            show_distance_div.addClass('opacity_04');
        } else {
            show_distance.prop('disabled', false);
            show_distance_div.removeClass('opacity_04');
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
            },
        });

        $('#top_bar_div').on('cocoon:after-insert', function(e, insertedItem, originalEvent) {
            var index = $('.top_bar_link_position').length - 1;
            insertedItem.find('.sort_priority_class').val(index);
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
            },
        });
    }


    $('.for-hide-content').on('change', function () {
       var checked = $(this).prop('checked'),
           private_content = $('.hide-content');
       if (checked) {
           private_content.removeClass('opacity_04');
       } else {
           private_content.addClass('opacity_04');
       }
    });

    $('.social-checked').on('change', function () {
       var input_elem = $(this).parents('.social-block').find('.social-data');
       if ($(this).prop('checked')) {
           input_elem.prop('required', true);
       } else {
           input_elem.prop('required', false);
       }
    });

    $('.change-file').on('change', function() {
       var place = $(this).parents('.custom-file').find('.choose-filename');
       place.hide();
    });

    if ($('#colorpicker-slogan').length) {
        $("#colorpicker-slogan, #colorpicker-description").spectrum({
            color: $(this).val(),
            showInput: true,
            preferredFormat: "hex",
            showPalette: true,
            showSelectionPalette: false,
            palette: [["#FFF", "#000", "#ED4F2E", "#15778E", "#ff5a5f"]]
        });
        $("#colorpicker-slogan, #colorpicker-description").show();
    }

    if ($('#colorpicker-color').length) {
        $("#colorpicker-color").spectrum({
            color: $(this).val(),
            showInput: true,
            preferredFormat: "hex",
            showPalette: true,
            showSelectionPalette: false,
            palette: [["#FFF", "#000", "#ED4F2E", "#15778E", "#ff5a5f"]]
        });
        $("#colorpicker-color").show();
    }

});
