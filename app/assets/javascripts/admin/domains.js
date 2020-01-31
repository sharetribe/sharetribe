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

  module.Domains = {
    init: init,
  };
})(window.ST);

