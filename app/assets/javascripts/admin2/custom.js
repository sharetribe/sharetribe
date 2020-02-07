function validateConfigureTransactions(community_id) {
    $("#edit_community_" + community_id).validate({
        errorPlacement: function (error, element) {
          $('#days_label').after(error);
        },
        onkeyup: false,
        onclick: false,
        onfocusout: false,
        onsubmit: true
    });
}

$(function(){

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
