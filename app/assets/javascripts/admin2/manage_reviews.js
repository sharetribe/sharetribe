function showReview(data) {
    $('#reviewReadLabel').text(data.reviewReadLabel);
    $('#customer_title').text(data.customer_title);
    $('#customer_status').text(data.customer_status);
    $('#customer_text').text(data.customer_text);
    $('#provider_title').text(data.provider_title);
    $('#provider_status').text(data.provider_status);
    $('#provider_text').text(data.provider_text);
    $('#reviewRead').modal('show');
}

$(function() {

    $(document).on('change', '.customer-delete-review', function () {
        if ($(this).prop('checked')) {
            $('.customer-blocked-review').prop('disabled', false);
        } else {
            if ($('#customer_blocked_disable').val() === 'true') {
                $('.customer-blocked-review').prop('disabled', true).prop('checked', false);
            }
        }
    });

    $(document).on('change', '.provider-delete-review', function () {
        if ($(this).prop('checked')) {
            $('.provider-blocked-review').prop('disabled', false);
        } else {
            if ($('#provider_blocked_disable').val() === 'true') {
                $('.provider-blocked-review').prop('disabled', true);
            }
        }
    });

});
