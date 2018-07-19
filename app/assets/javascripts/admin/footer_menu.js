window.ST = window.ST || {};

(function(module) {
  var init = function() {
    var fieldMap = $(".footer-menu-container").map(function(id, entry) {
      return {
        id: $(entry).data("field-id"),
        element: $(entry),
        up: $(".menu-link-action-up", entry),
        down: $(".menu-link-action-down", entry)
      };
    }).get();

    var fieldCount = fieldMap.length;

    var updateTableVisibility = function() {
      var $menuLinksTable = $("#menu-links-table");
      var $menuLinksEmpty = $("#menu-links-empty");

      if(fieldCount > 0) {
        $menuLinksTable.show();
        $menuLinksEmpty.hide();
      } else {
        $menuLinksTable.hide();
        $menuLinksEmpty.show();
      }
    };

    updateTableVisibility();

    var orderManager = window.ST.orderManager(fieldMap);

    var form = $('#footer-menu-form');
    form.on('click', '.menu-link-remove', function(event) {
      var container = $(this).closest('.footer-menu-container'),
        isNew = container.data('new');
      container.find('.destroy-record').val('1');
      if (isNew) {
        container.remove();
      } else {
        container.hide();
      }
      orderManager.remove(container.id);
      fieldCount--;
      updateTableVisibility();
      return event.preventDefault();
    });

    form.on('click', '.add-fields', function(event) {
      var time = new Date().getTime(),
        regexp = new RegExp($(this).data('id'), 'g'),
        templateId = $(this).data('templateId'),
        entry = $($(templateId).html().replace(regexp, time));
      $('#menu-links').append(entry);
      var newField = {
        id: entry.id,
        element: entry,
        up: $(".menu-link-action-up", entry),
        down: $(".menu-link-action-down", entry)
      };
      orderManager.add(newField);
      return event.preventDefault();
    });

    var submitHandler = function(form) {
      var index = 0;
      $(".sort-priority").each(function(){
        $(this).val(index);
        index++;
      });
      form.submit();
   };

    form.validate({submitHandler: submitHandler});
  };

  module.FooterMenu = {
    init: init
  };
})(window.ST);
