$(function() {

    $(document).on('click', '.approve-listing-link', function () {
        var id = $(this).data('id'),
            title_popup = $('#listingPendingModalLabel'),
            listing_name = $(this).data('title');

        title_popup.html(listing_name);
        $('#listing_id').val(id);
        $('#listingPendingModal').modal('show');
    });

    $(document).on('click', '.close-listing', function () {
        var id = $(this).data('id'),
            title_popup = $('#listingCloseModalLabel'),
            listing_name = $(this).data('title');

        title_popup.html(listing_name);
        $('#listing_close_id').val(id);
        $('#listingCloseModal').modal('show');
    });

    $(document).on('click', '.delete-listing', function () {
        var id = $(this).data('id'),
            title_popup = $('#listingDeleteModalLabel'),
            listing_name = $(this).data('title');

        title_popup.html(listing_name);
        $('#listing_delete_id').val(id);
        $('#listingDeleteModal').modal('show');
    });

    $(document).on('click', '.approve-listing', function () {
        var listing_state = $('#listing_state');
        listing_state.val('approved');
        $('#form_approve_reject').submit();
    });

    $(document).on('click', '.reject-listing', function () {
        var listing_state = $('#listing_state');
        listing_state.val('approval_rejected');
        $('#form_approve_reject').submit();
    });

    $(document).on('change', '.change-status-filter-listings', function () {
        $(this).parents('form').submit();
    });
});
