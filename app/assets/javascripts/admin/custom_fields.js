window.ST = window.ST || {};

(function(module) {
  var optionOrder, newOptionAdded;

  /**
    Add click handlers for the select/clear all links.
  */
  var initSelectionClickHandlers = function() {
    $(".select-all").click(function() {
      $(".custom-field-category-checkbox").prop("checked", true);
    });
    $(".deselect-all").click(function() {
      $(".custom-field-category-checkbox").prop("checked", false);
    });
  };

  /**
    Custom field order manager.

    Makes a POST request when order changes.
  */
  var createOrder = function() {
    /**
      Fetch all custom field rows and save them to a variable
    */
    var fieldMap = $(".custom-field-list-row").map(function(id, row) {
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
  var createOptionOrder = function(rowSelector) {

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
      newOptionAdded();
      optionOrder.add(newField);

      // Focus the new one
      row.find("input").first().focus();
    });

    return {
      remove: orderManager.remove,
      add: orderManager.add
    };
  };

  var removeLinkEnabledState = function(initialCount, minCount, containerSelector, linkSelector) {
    var enabled;
    var count = initialCount;
    update();

    $(containerSelector).on("click", linkSelector, function(event) {
      event.preventDefault();

      if(enabled) {
        var el = $(event.currentTarget);
        var container = el.closest(".custom-field-option-container");
        container.remove();
        optionOrder.remove(container.data("field-id"));
        count -= 1;
        update();
      }
    });

    function update() {
      enabled = count > minCount;

      $links = $(linkSelector);
      $links.addClass(enabled ? "enabled" : "disabled");
      $links.removeClass(!enabled ? "enabled" : "disabled");
    }

    return {
      add: function() {
        count += 1;
        update();
      }
    };

  };

  var initMainForm = function(options) {
    translate_validation_messages(options.locale);

    var form_id = "#custom_field_form";
    var $form = $(form_id);
    var CATEGORY_CHECKBOX_NAME = "custom_field[category_attributes][][category_id]";
    var MIN_NAME = "custom_field[min]";
    var MAX_NAME = "custom_field[max]";
    var DECIMAL_CHECKBOX = "custom_field[allow_decimals]";

    var rules = {};
    rules[CATEGORY_CHECKBOX_NAME] = {
      required: true
    };
    rules[MIN_NAME] = {
      min_bound: MAX_NAME,
      number_conditional_decimals: DECIMAL_CHECKBOX
    };
    rules[MAX_NAME] = {
      max_bound: MIN_NAME,
      number_conditional_decimals: DECIMAL_CHECKBOX
    };

    $form.validate({
      rules: rules,
      errorPlacement: function(error, element) {
        // Custom placement for checkbox group
        if (element.attr("name") === CATEGORY_CHECKBOX_NAME) {
          var container = $("#custom-field-categories-container");
          error.insertAfter(container);
        } else {
          error.insertAfter(element);
        }
      },
      submitHandler: function(form) {
        disable_and_submit(form_id, form, "false", options.locale);
      }
    });

    newOptionAdded = removeLinkEnabledState(options.option_count, options.min_count, "#options", ".custom-field-option-remove").add;
  };

  var initForm = function(options) {
    initMainForm(options);
    optionOrder = createOptionOrder(".custom-field-option-container");
    initSelectionClickHandlers();
  };

  var initList = function(options) {
    createOrder();
  };

  module.CustomFields = {
    initForm: initForm,
    initList: initList
  };
})(window.ST);
