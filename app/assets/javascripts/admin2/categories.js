function sortArray(nestedSortables) {
    for (var i = 0; i < nestedSortables.length; i++) {
        new Sortable(nestedSortables[i], {
            group: 'nested',
            animation: 250,
            fallbackOnBody: true,
            swapThreshold: 0.65,
            handle: '.handle-move',
            onEnd: function (/**Event*/evt) {
                var elem_id = evt.item.attributes['data-id'].value,
                    parent_elem_id,
                    array = [],
                    nestedList = $('#nestedList'),
                    url = nestedList.data('url'),
                    change_url = nestedList.data('change-url'),
                    content = $('.content-card-section');
                if (evt.to.attributes['data-id']) {
                    parent_elem_id = evt.to.attributes['data-id'].value;
                    $.post(change_url, {elem_id: elem_id, parent_elem_id: parent_elem_id});
                    content.find('.list-group-item[data-id='+ elem_id +']').removeClass('nested-1').addClass('nested-2').addClass('field-data');
                    content.find('.list-group-item[data-id='+ elem_id +']').find('.nested-sortable').remove();
                    content.find('.list-group-item[data-id='+ parent_elem_id +']').find('.nested-sortable').removeClass('empty-sortable');
                } else {
                    $.post(change_url, {elem_id: elem_id});
                    content.find('.list-group-item[data-id='+ elem_id +']').addClass('nested-1').removeClass('nested-2').removeClass('field-data');
                    var main_elem = content.find('.list-group-item[data-id='+ elem_id +']');
                    if (main_elem.find('.nested-sortable').length === 0) {
                        main_elem.append('<div class="empty-sortable list-group nested-sortable" data-id="'+ elem_id +'"></div>');
                        var nested = [].slice.call(document.querySelectorAll('.nested-sortable'));
                        sortArray(nested);
                    }
                }

                if (evt.from.attributes['data-id']) {
                    var old_parent = content.find('.list-group-item[data-id='+ evt.from.attributes['data-id'].value +']'),
                        child = old_parent.find('.nested-2');
                    if (child.length === 0) {
                        old_parent.find('.nested-sortable').addClass('empty-sortable');
                    }
                }

                $('.nested-1').each(function( index ) {
                    array.push($(this).data('id'));
                });
                $('.nested-2').each(function( index ) {
                    array.push($(this).data('id'));
                });
                $.post(url, {order: array});
            }
        });
    }
}

function validateCategory() {
    $(".edit_category, .new_category").validate({
        errorPlacement: function (error, element) {
           element.after(error);
        },
        onkeyup: false,
        onclick: false,
        onfocusout: false,
        onsubmit: true
    });
}

$(function(){

    if ($('#nestedList').length) {
        var nestedSortables = [].slice.call(document.querySelectorAll('.nested-sortable'));
        sortArray(nestedSortables);
    }

    $(document).on('click', '.remove-category', function () {
        var caption = $(this).data('caption'),
            url = $(this).data('url');
        $('#delete-category-form').attr('action', url);
        $('#categoriesDeleteModalSimpleLabel').html(caption);
        $('#categoriesDeleteModalSimple').modal('show');
    });

});
