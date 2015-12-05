window.ST.initializeBcc = function() {
  $(document).on('change', '#background_check_container_container_type', function(){
    if ($(this).val() == 'textfield' || $(this).val() == 'textarea') {
      $('.text_fields').removeClass('hidden');
      $('.file_fields').addClass('hidden');
    } else if ($(this).val() == 'file') {
      $('.text_fields').addClass('hidden');
      $('.file_fields').removeClass('hidden');
    }
  })
};