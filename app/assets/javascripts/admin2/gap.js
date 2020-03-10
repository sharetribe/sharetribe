jQuery(function(){

	// Mobile menu script
  $('#dismiss, .mobilemenu-overlay').on('click', function () {
    $('#mobilemenu').removeClass('active');
    $('#root').removeClass('active');
    $('.mobilemenu-overlay').removeClass('active');
  });
  $('#sidebarCollapse').on('click', function () {
    $('#mobilemenu').addClass('active');
    $('#root').addClass('active');
    $('.mobilemenu-overlay').addClass('active');
    $('.collapse.in').toggleClass('in');
    $('a[aria-expanded=true]').attr('aria-expanded', 'false');
  });

  // Add topnav-shadow class to .topnav element when scrolled 12px in mobile
  $(window).scroll(function(e) {
    if ($(window).scrollTop() > 12) {
      $('.topnav').addClass("topnav-shadow");
	    } else {
	      $('.topnav').removeClass("topnav-shadow");
    	}
  });

  $(window).scroll(function(e) {
    if ($(window).scrollTop() > 12) {
      $('.content-card-header').addClass("header-shadow");
	    } else {
	      $('.content-card-header').removeClass("header-shadow");
    	}
  });

    $(document).ready(function(){
        $('[data-toggle="tooltip"]').tooltip();
    });

});
