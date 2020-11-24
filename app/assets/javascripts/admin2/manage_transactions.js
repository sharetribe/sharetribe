$(function() {
    $(document).on('change', '.change-status-filter-transaction', function () {
        $(this).parents('form').submit();
    });
});
