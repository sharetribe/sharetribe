$(function(){

    var btn_waiting = $('#btn_waiting'),
        btn_waiting_send_email = $('#btn_waiting_send_email'),
        btn_text = $('#btn_text'),
        btn_text_send_email = $('#btn_text_send_email'),
        btn_completed = $('#btn_completed'),
        btn_completed_send_email = $('#btn_completed_send_email'),
        button = btn_text.closest('button'),
        button_send_email = btn_text_send_email.closest('a'),
        error_div = $('#error_save'),
        test_email_val = $('#test_email'),
        test_email = false;

    function beforeSubmit() {
        btn_waiting.show();
        btn_text.hide();
        button.prop('disabled', true);
        button_send_email.addClass('disabled');
        error_div.hide();
    }

    function beforeSubmitTest() {
        btn_waiting_send_email.show();
        btn_text_send_email.hide();
        button.prop('disabled', true);
        button_send_email.addClass('disabled');
        error_div.hide();
    }

    function successSubmit() {
        btn_waiting.hide();
        btn_completed.show();
        setTimeout(function() {
            btn_text.show();
            btn_completed.hide();
            button.prop('disabled', false);
            button_send_email.removeClass('disabled');
        }, 2000);
    }

    function successSubmitTest() {
        btn_waiting_send_email.hide();
        btn_completed_send_email.show();
        setTimeout(function() {
            btn_text_send_email.show();
            btn_completed_send_email.hide();
            button.prop('disabled', false);
            button_send_email.removeClass('disabled');
        }, 2000);
    }

    window.errorSubmit = function(msg) {
        btn_waiting.hide();
        btn_waiting_send_email.hide();
        btn_text.show();
        btn_text_send_email.show();
        button.prop('disabled', false);
        button_send_email.removeClass('disabled');
        error_div.text(msg);
        error_div.show();
    };

    $('form.email-form').on('ajax:send', function(e, data, status, xhr){
        if (test_email_val.val() === '1') {
            beforeSubmitTest();
        } else {
            beforeSubmit();
        }
    }).on('ajax:success', function(e, data, status, xhr){
        if (test_email_val.val() === '1') {
            successSubmitTest();
        } else {
            successSubmit();
        }
        test_email_val.val('0');
    }).on('ajax:error',function(e, xhr, status, error){
        errorSubmit(xhr.responseJSON['message']);
        test_email_val.val('0');
    });
});
