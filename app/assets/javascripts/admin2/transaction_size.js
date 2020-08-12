function validateTransactionSize() {
    var rules = {};
    rules['minimum_listing_price'] = {
        max: 21474836
    };
    $('form.transaction-size').validate({
        rules: rules
    });
}
