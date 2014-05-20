window.ST = window.ST || {};

window.ST.createMenuLinksOrder = function(rowSelector) {
  $menuLinks = $("#menu-links");
  var newMenuLinkTmpl = _.template($("#new-menu-link-tmpl").html());

  /**
    Fetch all custom field rows and save them to a variable
  */
  var fieldMap = $(rowSelector).map(function(id, row) {
    return {
      id: $(row).data("field-id"),
      element: $(row),
      sortPriority: Number($(row).find(".menu-link-hidden-sort-priority").val()),
      up: $(".menu-link-action-up", row),
      down: $(".menu-link-action-down", row)
    };
  }).get();

  var fieldCount = fieldMap.length;
  updateTableVisibility();

  var orderManager = window.ST.orderManager(fieldMap);

  orderManager.order.changes().onValue(function(changedFields) {
    var up = changedFields.up;
    var down = changedFields.down;

    var upHidden = up.element.find(".menu-links-hidden-sort-priority");
    var downHidden = down.element.find(".menu-links-hidden-sort-priority");

    var newUpValue = downHidden.val();
    var newDownValue = upHidden.val();

    upHidden.val(newUpValue);
    downHidden.val(newDownValue);
  });

  function initializeRemoveLink(obj) {
    $(".menu-link-remove", obj.element).click(function() {
      obj.element.remove();
      orderManager.remove(obj.id);
      fieldCount--;
      updateTableVisibility();
    });
  }

  // Initialize remove links
  fieldMap.forEach(initializeRemoveLink);

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

  $("#menu-links-add").click(function(e) {
    e.preventDefault();
    var id = "jsnew-" + nextId();
    var row = $(newMenuLinkTmpl({id: id, sortPriority: nextSortPriority()}));
    $menuLinks.append(row);
    var newField = {
      id: id,
      element: row,
      up: $(".menu-link-action-up", row),
      down: $(".menu-link-action-down", row)
    };
    orderManager.add(newField);

    initializeRemoveLink(newField);

    // Focus the new one
    row.find("input").first().focus();

    fieldCount++;
    updateTableVisibility();
  });

  function updateTableVisibility() {
    var $menuLinksTable = $("#menu-links-table");
    var $menuLinksEmpty = $("#menu-links-empty");

    if(fieldCount > 0) {
      $menuLinksTable.show();
      $menuLinksEmpty.hide();
    } else {
      $menuLinksTable.hide();
      $menuLinksEmpty.show();
    }
  }

};