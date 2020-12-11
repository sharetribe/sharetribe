function validateDomainForm() {
    $.validator.addMethod( "remove_protocol",
        function(value, element, param) {
            var protocolRegex = new RegExp("^(http|https)://");
            if (value.match(protocolRegex)) {
                $(element).val(value.replace(protocolRegex, ''));
            }
            return true;
        }
    );
    $.validator.addMethod( "valid_domain",
        function(value, element, param) {
            return value.match(new RegExp('(?=.{4,253})^(((?!-)[a-z0-9-]{0,62}[a-z0-9]\\.)+((?![0-9]+$)(?!-)[a-z0-9-]{0,62}[a-z0-9]))$'));
        }
    );
    $('form').validate();
}

function reserveDomainForm(options) {
    $.validator.
    addMethod( "exclude_reserved_domains",
        function(value, element, param) {
            return _.indexOf(options.reserved_domains, value.trim()) < 0;
        }
    );
    $.validator.
    addMethod( "valid_ident",
        function(value, element, param) {
            return value.match(new RegExp("^[A-Za-z0-9]([A-Za-z0-9\-]*)[A-Za-z0-9]$")) &&
                !value.match(/--/);
        }
    );
    $('form.edit_community').validate({
        submitHandler: function(form) {
            $('#sharetribeDomainChangeModal').modal('show');
            $('#apply_changes_domain').off('click').on('click', function(e) {
                form.submit();
            });
        }
    });
    $('form#domain_change_submit_form').validate();
}