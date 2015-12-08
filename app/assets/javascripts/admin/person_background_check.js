$(document).on('change', '#background_check_container', function(){
  var community_id = $('#community_id').val();
  var locale = $('#locale').val();
  var person_id = $(this).parents("tr").attr("id").split('_')[1];
  var bcc_id = $(this).val();
  $.ajax({
    url: '/' + locale + '/admin/communities/' + community_id + '/person_background_checks/bcc_status_select',
    type: 'GET',
    data: {
      person_id: person_id,
      bcc_id: bcc_id
    }
  });
})