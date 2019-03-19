window.ST = window.ST || {};
(function(module) {
  var initializeListingSearchFormSelector = function() {
    $(".status-select-button").click(function(){
      $(".status-select-dropdown").show();
      setTimeout(function() { document.addEventListener('mousedown', outsideClickListener);}, 300);
    });
    function updateSelectedStatus() {
      var v = [];
      $(".status-select-line input:checked").each(function(){
        v.push($(this).parent().text().trim());
      });
      if (v.length === 0) {
        v = [ST.t("admin.communities.listings.status.all")];
      } else {
        v = [ST.t("admin.communities.listings.status.selected_js") + v.length];
      }
      $(".status-select-button, .reset").text(v.join(", "));
    }
    $(".status-select-line").click(function(){
      var status = $(this).data("status");
      if (status == 'all') {
        $(".status-select-dropdown").hide();
        document.removeEventListener('mousedown', outsideClickListener);
      } else {
        var cb = $(this).find("input")[0];
        cb.checked = !cb.checked;
        $(this).toggleClass("selected");
      }
      updateSelectedStatus();
    });
    function outsideClickListener(evt) {
      if (!$(evt.target).closest(".status-select-line").length) {
        $(".status-select-dropdown").hide();
        document.removeEventListener('mousedown', outsideClickListener);
      }
    }
  };

  var init = function() {
    initializeListingSearchFormSelector();
  };

  var edit = function(options) {
    $('#listing-form').html(options.content);
    $('#listing_popup').lightbox_me({centered: true, closeSelector: '#close_x, #close_x1'});
    $('#listing-form input[type="submit"]').on('click', function() {
      $('#listing_state').val($(this).data('state'));
    });
  };

  var update = function(options) {
    if( !options.error ) {
      $('#listing_popup').trigger('close');
      $('#listing-' + options.id).replaceWith(options.content);
    } else {
      $('#listing-form').html(options.content);
    }
  };

  module.Listings = {
    init: init,
    edit: edit,
    update: update
  };

})(window.ST);

