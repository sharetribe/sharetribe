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

$(document).on('click', '.assign_status', function(){
  var community_id = $('#community_id').val();
  var locale = $('#locale').val();  
  var bcc_id = $(this).parents("tr").find('#background_check_container').val();
  var bcc_status_id = $(this).parents("tr").find('#background_check_container_status').val();
  var person_id = $(this).parents("tr").attr("id").split('_')[1];
  $.ajax({
    url: '/' + locale + '/admin/communities/' + community_id + '/person_background_checks/assign_status',
    type: 'POST',
    data: {
      person_id: person_id,
      bcc_id: bcc_id,
      bcc_status_id: bcc_status_id,
      person_id: person_id
    }
  });
})