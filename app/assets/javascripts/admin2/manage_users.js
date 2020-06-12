function banMembership(id) {
    var row = $('.membership-row-' + id);
    $('.row-member-' + id).addClass('opacity_04');
    row.find('.admin-members-is-admin').prop('disabled', true);
    row.find('.admin-members-can-post-listings').prop('disabled', true);
    row.find('.edit-membership').addClass('is-disabled');
    var can_post = row.find('.admin-members-can-post-listings');
    if (can_post.length === 0) {
        row.find('.post-membership').addClass('is-disabled');
    } else if (!can_post.prop('checked')) {
        row.find('.post-membership').addClass('is-disabled');
    }
}

function unbanMembership(id) {
    var row = $('.membership-row-' + id);
    $('.row-member-' + id).removeClass('opacity_04');
    row.find('.admin-members-is-admin').prop('disabled', false);
    row.find('.admin-members-can-post-listings').prop('disabled', false);
    row.find('.edit-membership').removeClass('is-disabled');
    var can_post = row.find('.admin-members-can-post-listings');
    if (can_post.length === 0) {
        row.find('.post-membership').removeClass('is-disabled');
    } else if (can_post.prop('checked')) {
        row.find('.post-membership').removeClass('is-disabled');
    } else {
        row.find('.post-membership').addClass('is-disabled');
    }
}

function processDeleteUser(id, can_delete, message) {
    var link = $('.membership-row-' + id).find('.delete-user');
    link.prop('title', message);
    if (can_delete) {
        link.removeClass('opacity_04');
        link.tooltip('dispose');
    } else {
        link.addClass('opacity_04');
        link.attr('data-original-title', message).tooltip();
    }
}

function allowPost(id) {
    var row = $('.membership-row-' + id);
    row.find('.post-membership').removeClass('is-disabled');
}

function disallowPost(id) {
    var row = $('.membership-row-' + id);
    row.find('.post-membership').addClass('is-disabled');
}

$(function() {

    $(document).on('click', '.confirm-user', function () {
        var name = $(this).data('name'),
            url = $(this).data('url');
        $('#userUnconfirmedModalLabel').html(name);
        $('#btn-send-confirm-user').attr('href', url);
        $('#userUnconfirmedModal').modal('show');
    });

    $(document).on('click', '.delete-user', function () {
        if($(this).hasClass('opacity_04')) {
            return false
        }
        var name = $(this).data('name'),
            url = $(this).data('url');
        $('#userDeleteModalLabel').html(name);
        $('#form-delete-user').attr('action', url);
        $('#userDeleteModal').modal('show');
    });

    $(document).on("click", ".admin-members-ban-toggle", function () {
        var banned = this.checked, url, msg;
        if (banned) {
            url = $(this).data("ban-url");
            msg = $(this).data('ban-msg');
        } else {
            url = $(this).data("unban-url");
            msg = $(this).data('unban-msg');
        }
        if (confirm(msg)) {
            $.ajax({
                type: "POST",
                url: url,
                dataType: "script",
                data: {_method: 'PATCH'}
            });
        } else {
            this.checked = !banned;
        }
    });

    $('.change-status-filter').on('change', function () {
        $(this).parents('form').submit();
    });

    $(document).on("click", ".admin-members-is-admin", function () {
        var admin = this.checked,
            url = $(this).data('url'),
            msg = $(this).data('msg'),
            id = $(this).val(),
            data, confirmation;

        if (!admin) {
            data = {remove_admin: id};
            confirmation = true;
        } else {
            data = {add_admin: id};
            confirmation = confirm(msg);
        }

        if (confirmation) {
            $.ajax({
                type: "POST",
                url: url,
                dataType: "script",
                data: data
            });
        } else {
            this.checked = !admin;
        }
    });

    $(document).on("click", ".admin-members-can-post-listings", function () {
        var can_post = this.checked,
            url = $(this).data('url'),
            id = $(this).val(), data;
        if (!can_post) {
            data = {disallowed_to_post: id};
        } else {
            data = {allowed_to_post: id};
        }
        $.ajax({
            type: 'patch',
            url: url,
            dataType: "script",
            data: data
        });
    });
});
