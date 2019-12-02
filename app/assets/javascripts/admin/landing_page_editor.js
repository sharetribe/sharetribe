window.ST = window.ST || {};

(function(module) {
  var optionOrder;

  /**
    Custom field option order manager.

    Changes `sort_priority` hidden field when order changes.
  */
  var createOptionOrder = function(rowSelector) {

    /**
      Fetch all custom field rows and save them to a variable
    */
    var fieldMap = $(rowSelector).map(function(id, row) {
      return {
        id: $(row).data("field-id"),
        element: $(row),
        sortPriority: Number($(row).find("[hidden-position]").val()),
        up: $("[action-up]", row),
        down: $("[action-down]", row)
      };
    }).get();

    var highestSortPriority = function(fieldMap) {
      return _(fieldMap)
        .map("sortPriority")
        .max()
        .value();
    };

    var nextSortPriority = (function(startValue) {
      var i = startValue;
      return function() {
        i += 1;
        return i;
      };
    })(highestSortPriority(fieldMap));

    var nextId = (function() {
      var i = 0;
      return function() {
        i += 1;
        return i;
      };
    })();

    var orderManager = window.ST.orderManager(fieldMap);

    orderManager.order.changes().onValue(function(changedFields) {
      var newOrder = changedFields.order,
        size = newOrder.length,
        up = changedFields.up,
        down = changedFields.down,
        index = 1;

      newOrder.forEach(function(value) {
        var item = $('[data-field-id="' + value + '"]'),
          downIcon = item.find('[action-down] i'),
          upIcon = item.find('[action-up] i');
        item.find('input[hidden-position]').val(index);
        if (index == 1) {
          upIcon.addClass('disabled');
        } else if (index == size) {
          downIcon.addClass('disabled');
        } else {
          downIcon.removeClass('disabled');
          upIcon.removeClass('disabled');
        }
        index++;
      });

      var form = $("form.edit_landing_page_version");
      $.ajax({
        url: form.attr('action'),
        type: 'PATCH',
        data: form.serialize()
      });
    });

    return {
      remove: orderManager.remove,
      add: orderManager.add
    };
  };

  var onSectionSelect = function(e) {
    var option = $(this).find('option:selected'),
      variation = option.data('variation'),
      multi_columns = option.data('multi-columns');

    $('#section_variation').val(variation);
    if (!variation) {
      $("#section_variation").attr('disabled', true);
    } else {
      $("#section_variation").attr('disabled', false);
    }
    $('#section_multi_columns').val(multi_columns).attr('disabled', !multi_columns);
    $(this).closest('form').submit();
  };

  var initForm = function(options) {
    optionOrder = createOptionOrder("[landing-page-version-section-position-row]");
    $('#section_kind').on('change', onSectionSelect);
  };

  module.LandingPageEditor = {
    initForm: initForm
  };
})(window.ST);
