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
      var up = changedFields.up;
      var down = changedFields.down;

      var upHidden = up.element.find("[hidden-position]");
      var downHidden = down.element.find("[hidden-position]");

      var newUpValue = downHidden.val();
      var newDownValue = upHidden.val();

      upHidden.val(newUpValue);
      downHidden.val(newDownValue);
    });

    return {
      remove: orderManager.remove,
      add: orderManager.add
    };
  };

  var initForm = function(options) {
    optionOrder = createOptionOrder(".landing-page-version-section-position-row");
  };

  module.LandingPageEditor = {
    initForm: initForm
  };
})(window.ST);
