/**
  Category order manager
*/
window.ST.initializeCategoriesOrder = function() {
  var fieldMap = $(".top-level-category-container").map(function(id, row) {
    return {
      id: $(row).data("id"),
      element: $(row),
      up: $(row).find(".top-level-category-row").find(".category-action-up"),
      down: $(row).find(".top-level-category-row").find(".category-action-down"),
    };
  }).get();

  var topLevelChanges = window.ST.orderManager(fieldMap).order;

  var subLevelChanges = $(".top-level-category-container").get().map(function(topLevelContainer) {
    var subFieldMap = $(".sub-category-row", topLevelContainer).map(function(id, row) {
      return {
        id: $(row).data("id"),
        element: $(row),
        up: $(".category-action-up", row),
        down: $(".category-action-down", row)
      };
    }).get();

    return window.ST.orderManager(subFieldMap).order;
  });

  var allChanges = [topLevelChanges].concat(subLevelChanges);

  var ajaxRequest = Bacon.combineAsArray(allChanges).changes()
    .debounce(800)
    .map(function(orders) {
      var onlyOrders = orders.map(function(obj) {
        return obj.order;
      });
      return _.flatten(onlyOrders);
    })
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
    $("#category-ajax-saving").show();
    $("#category-ajax-error").hide();
    $("#category-ajax-success").hide();
  });

  ajaxStatus.success.onValue(function() {
    $("#category-ajax-saving").hide();
    $("#category-ajax-success").show();
  });

  ajaxStatus.error.onValue(function() {
    $("#category-ajax-saving").hide();
    $("#category-ajax-error").show();
  });

  ajaxStatus.idle.onValue(function() {
    $("#category-ajax-success").fadeOut();
  });
};
