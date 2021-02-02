function checkedLandingPage(){
    var back_image = $('#info1ColBackgroundImageWrapper'),
        back_color = $('#info1ColBackgroundColorWrapper'),
        url = $('#info1ColCTALabelURLWrapper');

    back_image.hide();
    back_color.hide();
    url.hide();

    if ($('#section_cta_enabled').prop('checked')) {
        url.show();
    }
    if ($('#section_background_style_color').prop('checked')) {
        back_color.show();
    }
    if ($('#section_background_style_image').prop('checked')) {
        back_image.show();
    }
}
function initLandingPage(){
    $("#section_background_color_string").spectrum({
        showInput: true,
        preferredFormat: "hex",
        showPalette: true,
        showSelectionPalette: false,
        palette: [["#FFF", "#000", "#FF4E36", "#15778E", "#ff5a5f"]]
    });
    checkedLandingPage();
    $("form.section-form").validate();

}
$(function() {

    $(document).on('change', '.landing-page-section', function () {
        checkedLandingPage();
    });

    $('#section_kind').on('change', function(){
        var url = $(this).data('url'),
            id = $(this).val(),
            option = $(this).find('option:selected'),
            variation = option.data('variation'),
            multi_columns = option.data('multi-columns');

        $.get(url, {section: {kind: id, variation: variation, multi_columns: multi_columns}}, null, 'script');
    });

    if ($('#landingSection').length) {
        Sortable.create(landingSection, {
            handle: '.handle-move',
            animation: 250,
            onMove: function (/**Event*/evt, originalEvent) {
                if ($(evt.related).hasClass('allow_edit_false')) {
                    return false;
                }
            },
            onEnd: function (/**Event*/evt) {
                $('.top_bar_link_position').each(function (index) {
                    $(this).find('.sort_priority_class').val(index);
                });
                $('#simpleList').closest('form').find('button').prop('disabled', false);
            }
        });
    }
});
