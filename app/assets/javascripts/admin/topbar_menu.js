window.ST = window.ST || {};

window.ST.createMenuLinksOrder = function(rowSelector) {
  var $menuLinks = $("#menu-links");
  var newMenuLinkTmpl = _.template($("#new-menu-link-tmpl").html());

  /**
    Fetch all custom field rows and save them to a variable
  */
  var fieldMap = $(rowSelector).map(function(id, row) {
    return {
      id: $(row).data("field-id"),
      element: $(row),
      up: $(".menu-link-action-up", row),
      down: $(".menu-link-action-down", row)
    };
  }).get();

  var fieldCount = fieldMap.length;

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

  updateTableVisibility();

  var orderManager = window.ST.orderManager(fieldMap);

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

  $("#menu-links-add").click(function(e) {
    e.preventDefault();
    var id = _.uniqueId("jsnew-");
    var row = $(newMenuLinkTmpl({id: id}));
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

  $("#topbar-menu-form").validate();

};
