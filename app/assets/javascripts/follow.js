window.ST.onFollowButtonAjaxComplete = function(event, xhr) {
  var target = $(event.target);
  var newButtonContainer = $(xhr.responseText);

  // Work around "Unfollow" showing up too soon
  $(".button-hoverable", newButtonContainer).addClass("button-disable-hover");
  newButtonContainer.on(
    "mouseleave", function() { 
      $(".button-disable-hover", newButtonContainer).removeClass("button-disable-hover"); 
    }
  );

  target.parents(".follow-button-container:first").replaceWith(newButtonContainer);
  $(".follow-button", newButtonContainer).on("ajax:complete", window.ST.onFollowButtonAjaxComplete);
};

window.ST.initializeFollowButtons = function() {
  $(".follow-button").on("ajax:complete", window.ST.onFollowButtonAjaxComplete);
};
