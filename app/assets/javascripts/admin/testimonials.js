window.ST = window.ST || {};
(function(module) {
  var init = function(options) {
    $(document).on('click', '#thumbs-up', function() {
      $(this).removeClass('faded').addClass('positive');
      $('#thumbs-down').removeClass('negative').addClass('faded');
      $('#testimonial_grade').val('1');
    });
    $(document).on('click', '#thumbs-down', function() {
      $(this).removeClass('faded').addClass('negative');
      $('#thumbs-up').removeClass('positive').addClass('faded');
      $('#testimonial_grade').val('0');
    });
  };

  var edit = function(options) {
    $('#testimonial-form').html(options.content);
    $('#testimonial_popup').lightbox_me({centered: true, closeSelector: '#close_x'});
    $(document).tooltip();
  };

  var update = function(options) {
    if( !options.error ) {
      $('#testimonial_popup').trigger('close');
      $('#testimonial-' + options.id).replaceWith(options.content);
    } else {
      $('#testimonial-form').html(options.content);
    }
  };

  module.Testimonials = {
    init: init,
    edit: edit,
    update: update
  };
})(window.ST);
