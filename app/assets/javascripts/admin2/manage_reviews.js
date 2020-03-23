function showReview(data) {
    $('#reviewReadLabel').html(data.reviewReadLabel);
    $('#customer_title').html(data.customer_title);
    $('#customer_status').html(data.customer_status);
    $('#customer_text').html(data.customer_text);
    $('#provider_title').html(data.provider_title);
    $('#provider_status').html(data.provider_status);
    $('#provider_text').html(data.provider_text);
    $('#reviewRead').modal('show');
}

$(function() {

    $(document).on('change', '.customer-delete-review', function () {
        if ($(this).prop('checked')) {
            $('.customer-blocked-review').prop('disabled', false);
        } else {
            if ($('#customer_blocked_disable').val() === 'true') {
                $('.customer-blocked-review').prop('disabled', true);
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
