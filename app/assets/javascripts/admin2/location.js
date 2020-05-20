$(function(){

    $('#community_show_location').on('change', function () {
        var fuzzy = $('#community_fuzzy_location');
        if ($(this).prop('checked')) {
            fuzzy.prop('disabled', false);
        } else {
            fuzzy.prop('disabled', true);
            fuzzy.prop('checked', false);
        }
    });

});
