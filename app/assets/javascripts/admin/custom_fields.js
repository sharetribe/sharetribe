window.ST = window.ST || {};

/**
  Custom field order manager.

  Makes a POST request when order changes.
*/
window.ST.createCustomFieldOrder = function(rowSelector) {

  /**
    Fetch all custom field rows and save them to a variable
  */
  var fieldMap = $(rowSelector).map(function(id, row) {
    return {
      id: $(row).data("field-id"),
      element: $(row),
      up: $(".custom-fields-action-up", row),
      down: $(".custom-fields-action-down", row)
    };
  }).get();

  var orderManager = window.ST.orderManager(fieldMap);

  var ajaxRequest = orderManager.order.changes().debounce(800).map(".order")
    .skipDuplicates(_.isEqual)
    .map(function(order) {
    return {
      type: "POST",
      url: ST.utils.relativeUrl("order"),
      data: { order: order }
    };
  });

  var ajaxResponse = ajaxRequest.ajax();
  var ajaxStatus = window.ST.ajaxStatusIndicator(ajaxRequest, ajaxResponse);

  ajaxStatus.loading.onValue(function() {
    $("#custom-field-ajax-saving").show();
    $("#custom-field-ajax-error").hide();
    $("#custom-field-ajax-success").hide();
  });

  ajaxStatus.success.onValue(function() {
    $("#custom-field-ajax-saving").hide();
    $("#custom-field-ajax-success").show();
  });

  ajaxStatus.error.onValue(function() {
    $("#custom-field-ajax-saving").hide();
    $("#custom-field-ajax-error").show();
  });

  ajaxStatus.idle.onValue(function() {
    $("#custom-field-ajax-success").fadeOut();
  });
};

/**
  Custom field option order manager.

  Changes `sort_priority` hidden field when order changes.
*/
window.ST.createCustomFieldOptionOrder = function(rowSelector) {

  /**
    Fetch all custom field rows and save them to a variable
  */
  var fieldMap = $(rowSelector).map(function(id, row) {
    return {
      id: $(row).data("field-id"),
      element: $(row),
      sortPriority: Number($(row).find(".custom-field-hidden-sort-priority").val()),
      up: $(".custom-fields-action-up", row),
      down: $(".custom-fields-action-down", row)
    };
  }).get();

  function highestSortPriority(fieldMap) {
    return _(fieldMap)
      .map("sortPriority")
      .max()
      .value();
  }

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
    var up = changedFields.up;
    var down = changedFields.down;

    var upHidden = up.element.find(".custom-field-hidden-sort-priority");
    var downHidden = down.element.find(".custom-field-hidden-sort-priority");

    var newUpValue = downHidden.val();
    var newDownValue = upHidden.val();

    upHidden.val(newUpValue);
    downHidden.val(newDownValue);
  });

  var newOptionTmpl = _.template($("#new-option-tmpl").html());
  var $customFieldOptions = $("#options");

  $("#custom-fields-add-option").click(function(e) {
    e.preventDefault();
    var id = "jsnew-" + nextId();
    var row = $(newOptionTmpl({id: id, sortPriority: nextSortPriority()}));
    $customFieldOptions.append(row);
    var newField = {
      id: id,
      element: row,
      up: $(".custom-fields-action-up", row),
      down: $(".custom-fields-action-down", row)
    };
    ST.newOptionAdded();
    ST.customFieldOptionOrder.add(newField);

    // Focus the new one
    row.find("input").first().focus();
  });

  return {
    remove: orderManager.remove,
    add: orderManager.add
  };
};
