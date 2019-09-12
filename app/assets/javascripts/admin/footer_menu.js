window.ST = window.ST || {};

(function(module) {
  var init = function() {
    var socialFieldMap = $(".footer-social-container").map(function(id, entry) {
      return {
        id: $(entry).data("field-id"),
        element: $(entry),
        up: $(".menu-link-action-up", entry),
        down: $(".menu-link-action-down", entry)
      };
    }).get();

    window.ST.orderManager(socialFieldMap);

    var fieldMap = $(".footer-menu-container").map(function(id, entry) {
      return {
        id: $(entry).data("field-id"),
        element: $(entry),
        up: $(".menu-link-action-up", entry),
        down: $(".menu-link-action-down", entry)
      };
    }).get();

    var fieldCount = fieldMap.length;

    var updateVisibilityByCount = function() {
      var minValue = $("input[count-validation][data-min]").data("min");
      var maxValue = $("input[count-validation][data-max]").data("max");
      if (!minValue || !maxValue) return;
      // toggle error message
      $("input[count-validation]").valid();
      if (fieldCount >= maxValue) {
        $(".add-fields").prop('disabled', true).addClass('disabled');
      } else {
        $(".add-fields").prop('disabled', false).removeClass('disabled');
      }
    };

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
      updateVisibilityByCount();
    };

    updateTableVisibility();

    var orderManager = window.ST.orderManager(fieldMap);

    var form = $('#footer-menu-form, #edit_section_footer, form.section-categories-form, form.section-locations-form');
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
      fieldCount++;
      updateTableVisibility();
      return event.preventDefault();
    });

    var setSortPriority = function(selector) {
      var index = 0;
      $(selector).each(function(){
        $(this).val(index);
        index++;
      });
    };

    var submitHandler = function(form) {
      setSortPriority("#menu-links .sort-priority");
      setSortPriority("#social-links .sort-priority");
      form.submit();
    };

    $('.social-link-check-box').on('change', function() {
      var provider = $(this).data('provider'),
        socialLink = $('.social-link-required[provider="' + provider + '"]');
      if ($(this).is(":checked")) {
        socialLink.removeClass('ignore-validation');
      } else {
        socialLink.addClass('ignore-validation');
      }
    });

    form.validate({
      submitHandler: submitHandler,
      ignore: ":hidden:not(.custom-validation), .ignore-validation"
    });
  };

  module.FooterMenu = {
    init: init
  };
})(window.ST);
