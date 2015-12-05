window.ST.initializeBcc = function() {
  $(document).on('change', '#background_check_container_container_type', function(){
    if ($(this).val() == 'textfield') { // || $(this).val() == 'textarea'
      console.log('1')
      console.log($(this).val())
      $('.text_fields').removeClass('hidden');
      $('.file_fields').addClass('hidden');
    } else if ($(this).val() == 'file') {
      console.log('2')
      console.log($(this).val())
      $('.text_fields').addClass('hidden');
      $('.file_fields').removeClass('hidden');
    }
  })
};