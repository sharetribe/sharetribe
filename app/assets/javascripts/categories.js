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

  orderManager = window.ST.orderManager(fieldMap);

  function customFieldUrl(url) {
    return [window.location.pathname, url].join("/").replace("//", "/");
  }

  orderManager.changes.log("LOG")

  var ajaxRequest = orderManager.changes.debounce(800).map(".order")
    .skipDuplicates(_.isEqual)
    .map(function(order) {
    return {
      type: "POST",
      url: customFieldUrl("order"),
      data: { order: order }
    };
  });

  ajaxRequest.log("ajax request!");

  var ajaxResponse = ajaxRequest.ajax()
    .map(function() { return true; })
    .mapError(function() { return false; });

  ajaxResponse.log("RESPONSE!")

  $(".top-level-category-container").each(function(idx, topLevelContainer) {
    var subFieldMap = $(".sub-category-row", topLevelContainer).map(function(id, row) {
      return { 
        id: $(row).data("id"),
        element: $(row),
        up: $(".category-action-up", row),
        down: $(".category-action-down", row)
      };
    }).get();

    orderManager = window.ST.orderManager(subFieldMap);
    
    var ajaxRequest = orderManager.changes.debounce(800).map(".order")
      .skipDuplicates(_.isEqual)
      .map(function(order) {
      return {
        type: "POST",
        url: customFieldUrl("order"),
        data: { order: order }
      };
    });

    ajaxRequest.log("ajax request!");

    var ajaxResponse = ajaxRequest.ajax()
      .map(function() { return true; })
      .mapError(function() { return false; });

    ajaxResponse.log("RESPONSE!")
  });
};