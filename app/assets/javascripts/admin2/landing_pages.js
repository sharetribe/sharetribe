$(function() {
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