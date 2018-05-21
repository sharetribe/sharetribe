window.ST = window.ST || {};

/**
  Maganage members in admin UI
*/
window.ST.initializeManageMembers = function() {
  var DELAY = 800;

  function createCheckboxAjaxRequest(streams, url, allowedKey, disallowedKey) {
    var ajaxRequest = Bacon.combineAsArray(streams).changes().debounce(DELAY).skipDuplicates(_.isEqual).map(function(valueObjects) {
      function isValueTrue(valueObject) {
        return valueObject.checked;
      }

      var data = {};
      data[allowedKey] = _.filter(valueObjects, isValueTrue).map(function(input){ return input.value; });
      data[disallowedKey] = _.reject(valueObjects, isValueTrue).map(function(input){ return input.value; });

      return {
        type: "POST",
        url: ST.utils.relativeUrl(url),
        data: data
      };
    });

    return ajaxRequest;
  }

  var showUpdateNotification = function() {
    $(".ajax-update-notification").show();
    $("#admin-members-saving-posting-allowed").show();
    $("#admin-members-error-posting-allowed").hide();
    $("#admin-members-saved-posting-allowed").hide();
  };

  var showUpdateSuccess = function() {
    $("#admin-members-saving-posting-allowed").hide();
    $("#admin-members-saved-posting-allowed").show();
  };

  var showUpdateError = function() {
    $("#admin-members-saving-posting-allowed").hide();
    $("#admin-members-error-posting-allowed").show();
  };

  var showUpdateIdle = function() {
    $(".ajax-update-notification").fadeOut();
  };

  var initBanToggle = function () {
    $(document).on("click", ".admin-members-ban-toggle", function(){
      var banned = this.checked;
      var row = $(this).parent().parent()[0];
      var confirmation, url;
      if(banned) {
        confirmation = ST.t('admin.communities.manage_members.ban_user_confirmation');
        url = $(this).data("ban-url");
      } else {
        confirmation = ST.t('admin.communities.manage_members.unban_user_confirmation');
        url = $(this).data("unban-url");
      }
      if(confirm(confirmation)) {
        showUpdateNotification();
        $.ajax({
          type: "PUT",
          url: url,
          dataType: "JSON",
          success: function(resp) {
            row.className = "member-"+resp.status;
            showUpdateSuccess();
          },
          error: showUpdateError,
          complete: _.debounce(showUpdateIdle, DELAY)
        });
      } else {
        this.checked = !banned;
      }
    });
  };

  var adminStreams = $(".admin-members-is-admin").asEventStream('change')
    .map(function (ev) {
      return ev.target;
    })
    .filter(function (target) {
      if (target.checked) {
        if (confirm(ST.t('admin.communities.manage_members.this_makes_the_user_an_admin'))) {
          return true;
        }
        target.checked = !target.checked;
        return false;
      }
      return true;
    });

  var postingAllowedStreams = $(".admin-members-can-post-listings").asEventStream('change')
    .map(function (ev) {
      return ev.target;
    });

  var postingAllowed = createCheckboxAjaxRequest(postingAllowedStreams, "posting_allowed", "allowed_to_post", "disallowed_to_post");
  var isAdmin = createCheckboxAjaxRequest(adminStreams, "promote_admin", "add_admin", "remove_admin");

  var ajaxRequest = postingAllowed.merge(isAdmin);
  var ajaxResponse = ajaxRequest.ajax().endOnError();

  var ajaxStatus = window.ST.ajaxStatusIndicator(ajaxRequest, ajaxResponse);

  ajaxStatus.loading.onValue(showUpdateNotification);
  ajaxStatus.success.onValue(showUpdateSuccess);
  ajaxStatus.error.onValue(showUpdateError);
  ajaxStatus.idle.onValue(showUpdateIdle);

  // Attach analytics click handler for CSV export
  $(".js-users-csv-export").click(function(){
    window.ST.analytics.logEvent('admin', 'export', 'users');
  });

  initBanToggle();
};
