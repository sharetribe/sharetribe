window.ST = window.ST || {};
(function(module) {
  var showIntercom = function(e) {
    e.preventDefault();
    if (window.Intercom) {
      window.Intercom('show');
    }
  };

  var init = function(options) {
    $('[show-intercom]').on('click', showIntercom);
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
        $('#domain_popup').lightbox_me({centered: true, closeSelector: '#close_x, #close_x1'});
        $('#proceed').off('click').on('click', function(e) {
          form.submit();
        });
      }
    });
  };

  var initDomainAvailability = function(options) {
    $.validator.
      addMethod( "remove_protocol",
        function(value, element, param) {
          var protocolRegex = new RegExp("^(http|https)://");
          if (value.match(protocolRegex)) {
            $(element).val(value.replace(protocolRegex, ''));
          }
          return true;
        }
      );
    $.validator.
      addMethod( "valid_domain",
       function(value, element, param) {
         v = punycode.toASCII(value);
         return v.match(new RegExp('(?=.{4,253})^(((?!-)[a-z0-9-]{0,62}[a-z0-9]\\.)+((?![0-9]+$)(?!-)[a-z0-9-]{0,62}[a-z0-9]))$'));
       }
     );
    $('form.create_domain_setup').validate();
  };


  module.Domains = {
    init: init,
    initDomainAvailability: initDomainAvailability,
  };
})(window.ST);
