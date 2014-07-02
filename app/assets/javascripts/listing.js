window.ST = window.ST || {};

window.ST.listing = function() {
  $('#add-to-weekly-email').on('click', function() {
    var text = $(this).find('#add-to-weekly-email-text');
    var actionLoading = text.data('action-loading');
    var actionSuccess = text.data('action-success');
    var actionError = text.data('action-error');
    var url = $(this).attr('href');

    text.html(actionLoading);

    $.ajax({
      url: url,
      type: "PUT",
    }).done(function() {
      text.html(actionSuccess);
    }).fail(function() {
      text.html(actionError);
    });
  });
}