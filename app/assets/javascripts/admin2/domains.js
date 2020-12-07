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

$(function(){



});