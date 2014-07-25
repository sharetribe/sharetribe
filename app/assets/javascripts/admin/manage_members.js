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

  function createCheckboxAjaxRequest(selector, url, allowedKey, disallowedKey) {
    var streams = $(selector).toArray().map(function(domElement) {
      return $(domElement).asEventStream("change").map(function(event){
        return elementToValueObject(event.target);
      }).toProperty(elementToValueObject(domElement));
    });

    var ajaxRequest = Bacon.combineAsArray(streams).changes().debounce(800).skipDuplicates(_.isEqual).map(function(valueObjects) {
      function isValueTrue(valueObject) {
        return _.values(valueObject)[0];
      }

      var allowed = _.filter(valueObjects, isValueTrue);
      var disallowed = _.reject(valueObjects, isValueTrue);

      var data = {};
      data[allowedKey] = _.keys(ST.utils.objectsMerge(allowed));
      data[disallowedKey] = _.keys(ST.utils.objectsMerge(disallowed));

      return {
        type: "POST",
        url: ST.utils.relativeUrl(url),
        data: data
      };
    });

    return ajaxRequest;
  }

  var postingAllowed = createCheckboxAjaxRequest(".admin-members-can-post-listings", "posting_allowed", "allowed_to_post", "disallowed_to_post");
  var isAdmin = createCheckboxAjaxRequest(".admin-members-is-admin", "promote_admin", "add_admin", "remove_admin");

  var ajaxRequest = postingAllowed.merge(isAdmin);
  var ajaxResponse = ajaxRequest.ajax().endOnError();

  var ajaxStatus = window.ST.ajaxStatusIndicator(ajaxRequest, ajaxResponse);

  ajaxStatus.loading.onValue(function() {
    $(".ajax-update-notification").show();
    $("#admin-members-saving-posting-allowed").show();
    $("#admin-members-error-posting-allowed").hide();
    $("#admin-members-saved-posting-allowed").hide();
  });

  ajaxStatus.success.onValue(function() {
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
};
