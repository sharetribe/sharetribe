function closeAllToggleMenus() {
  $('.toggle-menu').addClass('hidden');
  $('.toggle-menu-feed-filters').addClass('hidden');
  $('.toggle').removeClass('toggled');
  $('.toggle').removeClass('toggled-logo');
  $('.toggle').removeClass('toggled-full-logo');
  $('.toggle').removeClass('toggled-icon-logo');
  $('.toggle').removeClass('toggled-no-logo');
}

function toggleDropdown(event_target) {

  //Gets the target toggleable menu from the link's data-attribute
  var target = event_target.attr('data-toggle');
  var anchorElement = event_target.attr('data-toggle-anchor-element') || event_target;
  var anchorPosition = event_target.attr('data-toggle-anchor-position') || "left";
  var togglePosition = event_target.attr('data-toggle-position') || "relative";
  var logo_class = event_target.attr('data-logo_class');

  if ($(target).hasClass('hidden')) {
    // Opens the target toggle menu
    closeAllToggleMenus();
    $(target).removeClass('hidden');
    if(event_target.hasClass('select-tribe')) {
      event_target.addClass('toggled-logo');
      if (logo_class != undefined) {
        event_target.addClass(logo_class);
      }
    } else {
      event_target.addClass('toggled');

      if (togglePosition == "absolute") {
        var anchorOffset = anchorElement.offset();
        var top = anchorOffset.top + anchorElement.outerHeight();
        var left = anchorOffset.left;
        var right = left - ($(target).outerWidth() - anchorElement.outerWidth());
        $(target).css("top", top);

        if(anchorPosition == "right") {
          $(target).css("left", right);
        } else {
          $(target).css("left", left);
        }
      }
    }
  } else {
    // Closes the target toggle menu
    $(target).addClass('hidden');
    event_target.removeClass('toggled');
    event_target.removeClass('toggled-logo');
    if (logo_class != undefined) {
      event_target.removeClass(logo_class);
    }
  }

}

$(function(){

  $('.toggle').click( function(event){
    event.stopPropagation();
    toggleDropdown($(this));
  });

  $('.toggle-menu').click( function(event){
    event.stopPropagation();
  });

  $('.toggle-menu-feed-filters').click( function(event){
    event.stopPropagation();
  });

  // All dropdowns are collapsed when clicking outside dropdown area
  $(document).click( function(){
    closeAllToggleMenus();
  });

});