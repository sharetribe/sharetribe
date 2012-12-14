function closeAllToggleMenus() {
  $('.toggle-menu').addClass('hidden');
  $('.toggle-menu-filters').addClass('hidden');
  $('.toggle').removeClass('toggled');
  $('.toggle').removeClass('toggled-logo');
}

$(function(){
  
  // Collapses all toggle menus on load
  // They're uncollapsed by default to provice support for when JS is turned off
  closeAllToggleMenus();
  
  $('.toggle').on('click', function() {
    
    // Gets the target toggleable menu from the link's data-attribute
    var target = $(this).attr('data-toggle');
    
    if ($(target).hasClass('hidden')) {
      // Opens the target toggle menu
      closeAllToggleMenus();
      $(target).removeClass('hidden');
      if($(this).hasClass('select-tribe')) {
        $(this).addClass('toggled-logo');
      } else {
        $(this).addClass('toggled');
      }
    } else {
      // Closes the target toggle menu
      $(target).addClass('hidden');
      $(this).removeClass('toggled');
      $(this).removeClass('toggled-logo');
    }
    
    
    
  });
    
});