var btn_waiting = $('#btn_waiting'),
    btn_text = $('#btn_text'),
    btn_completed = $('#btn_completed'),
    button = btn_text.closest('button'),
    error_div = $('#error_save');

function beforeSubmit() {
    btn_waiting.show();
    btn_text.hide();
    button.prop('disabled', true);
    error_div.hide();
}

function successSubmit() {
    btn_waiting.hide();
    btn_completed.show();
    setTimeout(function() {
        btn_text.show();
        btn_completed.hide();
    }, 2000);
}

function errorSubmit(msg) {
    btn_waiting.hide();
    btn_text.show();
    button.prop('disabled', false);
    error_div.text(msg);
    error_div.show();
}

$(function(){

    $('form input, form select').on('change keyup', function(e) {
        $(this).closest('form').find('button').prop('disabled', false);
    });

    $('form').on('ajax:send', function(e, data, status, xhr){
        beforeSubmit();
    }).on('ajax:success', function(e, data, status, xhr){
        successSubmit();
    }).on('ajax:error',function(e, xhr, status, error){
        errorSubmit(xhr.responseJSON['message']);
    });

    $("form.form-with-files").submit(function(e) {
        e.preventDefault();
        beforeSubmit();
        var formData = new FormData(this),
            url = $(this).attr("action");
        $.ajax({
            url: url,
            type: 'PATCH',
            data: formData,
            success: function (data) {
                successSubmit();
            },
            cache: false,
            contentType: false,
            processData: false
        });
    });
});
