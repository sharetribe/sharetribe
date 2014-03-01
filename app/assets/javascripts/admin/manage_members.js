window.ST = window.ST || {};

/**
  Maganage members in admin UI
*/
window.ST.initializeManageMembers = function() {
  function elementToValueObject(element) {
    var r = {};
    r[$(element).val()] = !! $(element).attr("checked");
    return r;
  }
  
  var streams = $(".admin-members-can-post-listings").toArray().map(function(domElement) { 
    return $(domElement).asEventStream("change").map(function(event){
      return elementToValueObject(event.target);

    }).toProperty(elementToValueObject(domElement))
  })


  var ajaxRequest = Bacon.combineAsArray(streams).changes().debounce(800).skipDuplicates(_.isEqual).map(function(valueObjects) {
    function isValueTrue(valueObject) {
      return _.values(valueObject)[0];
    }

    var allowed = _.filter(valueObjects, isValueTrue);
    var disallowed = _.reject(valueObjects, isValueTrue);

    return {
      type: "POST",
      url: ST.utils.relativeUrl("../posting_allowed"),
      data: {
        allowed_to_post: _.keys(ST.utils.objectsMerge(allowed)),
        disallowed_to_post: _.keys(ST.utils.objectsMerge(disallowed))
      }
    };
  });

  var ajaxResponse = ajaxRequest.ajax();

  var ajaxStatus = window.ST.ajaxStatusIndicator(ajaxRequest, ajaxResponse);

  ajaxStatus.loading.onValue(function() {
    $(".ajax-update-notification").show();
    $("#admin-members-saving-posting-allowed").show();
    $("#admin-members-error-posting-allowed").hide();
    $("#admin-members-saved-posting-allowed").hide();
  });

  ajaxStatus.success.onValue(function(v) {
    $("#admin-members-saving-posting-allowed").hide();
    $("#admin-members-saved-posting-allowed").show();
  });

  ajaxStatus.error.onValue(function() {
    $("#admin-members-saving-posting-allowed").hide();
    $("#admin-members-error-posting-allowed").show();
  });

  ajaxStatus.idle.onValue(function() {
    $(".ajax-update-notification").fadeOut();
  });
}
