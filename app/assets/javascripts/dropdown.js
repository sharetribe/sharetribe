$(function() {
  var toggles = [];

  function closeAll() {
    toggles.forEach(function(toggle) {
      toggle.close();
    });
  }

  function toggleMenu(el) {
    var $menu = $(el.attr('data-toggle'));
    var anchorElement = $(el.attr('data-toggle-anchor-element') || el);
    var anchorPosition = el.attr('data-toggle-anchor-position') || "left";
    var togglePosition = el.attr('data-toggle-position') || "relative";

    function absolutePosition() {
      var anchorOffset = anchorElement.offset();
      var top = anchorOffset.top + anchorElement.outerHeight();
      var left = anchorOffset.left;

      if(anchorPosition === "right") {
        var right = left - ($menu.outerWidth() - anchorElement.outerWidth());
        $menu.css("left", right);
      } else {
        $menu.css("left", left);
      }

      $menu.css("top", top);
    }

    function open() {
      // Opens the menu toggle menu
      closeAll();

      if (togglePosition === "absolute") {
        absolutePosition();
      }

      $menu.removeClass('hidden');
      el.addClass('toggled');
      toggleFn = close;
    }

    function close() {
      // Closes the target toggle menu
      $menu.addClass('hidden');
      el.removeClass('toggled');
      toggleFn = open;
    }

    var toggleFn = open;

    el.click(function(event) {
      event.stopPropagation();
      toggleFn();
    });

    $menu.click(function(event){
      event.stopPropagation();
    });

    return {
      close: close
    };
  }

  // Initialize menu
  toggles = _.toArray($('.toggle')).map(function(el) {
    return toggleMenu($(el));
  });

  // All dropdowns are collapsed when clicking outside dropdown area
  $(document).click( function(){
    closeAll();
  });
});