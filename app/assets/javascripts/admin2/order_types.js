$(function() {

    $('#orderTypesAddModal'). on('show.bs.modal', function() {
        $('#template_order_type option[value=""]').show();
        $('#template_order_type').prop('selectedIndex', 0);
        $('#category-body').html('');
        $('.order-type-footer').hide();
    });

    $(document).on('click', '.confirm-order-type-true', function () {
        var caption = $(this).data('caption'),
            url = $(this).data('url'),
            notice = $(this).data('notice');
        $('#delete-order-type-body').html(notice);
        $('#delete-order-form').attr('action', url);
        $('#orderTypesDeleteModalLabel').html(caption);
        $('#orderTypesDeleteModal').modal('show');
    });

    $(document).on('click', '.confirm-order-type-false', function () {
        var caption = $(this).data('caption'),
            url = $(this).data('url'),
            notice = $(this).data('notice');
        $('#delete-simple-order-type-body').html(notice);
        $('#delete-simple-order-form').attr('action', url);
        $('#orderTypesDeleteModalSimpleLabel').html(caption);
        $('#orderTypesDeleteModalSimple').modal('show');
    });

    $('#template_order_type').on('change', function(){
        var url = $(this).data('url'),
            id = $(this).val();
        $.get(url, {type_id: id}, null, 'script');
    });

    var orderList = $('#orderTypeList');
    if (orderList.length) {
        var url = orderList.data('url');
        Sortable.create(orderTypeList, {
            handle: '.handle-move',
            animation: 250,
            onEnd: function (/**Event*/evt) {
                $('.order_type_position').each(function( index ) {
                    $(this).find('.shape_sort_priority').val(index);
                });
                var ids = [];
                $('.order_type_position').each(function( index ) {
                    var input = $(this).find('.shape_sort_priority'),
                        id = input.data('id'),
                        position = input.val();

                    ids.push({id: id, position: position});
                });
                $.post(url, {ids: ids});
            },
        });

        $('#top_bar_div').on('cocoon:after-insert', function(e, insertedItem, originalEvent) {
            var index = $('.top_bar_link_position').length - 1;
            insertedItem.find('.sort_priority_class').val(index);
        });
    }

});
