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
    $(document).tooltip();
    $(document).on("click", ".admin-members-ban-toggle", function(){
      var banned = this.checked;
      var row = $(this).parent().parent();
      var unfinishedTransactions = row.data('unfinishedTransactions');
      var confirmation, url;
      var updateRowSuccess = function(resp) {
        var actions = row.find('.membership-actions span'),
          manage = actions.not('.delete-member'),
          remove = actions.filter('.delete-member');
        row[0].className = "member-"+resp.status;
        if( resp.status == 'banned' ) {
          manage.addClass('is-disabled');
          if (unfinishedTransactions) {
            remove.attr('title', ST.t('admin.communities.manage_members.have_ongoing_transactions'));
          } else {
            remove.removeClass('is-disabled');
            remove.attr('title', null);
          }
        } else {
          manage.removeClass('is-disabled');
          remove.addClass('is-disabled');
          if (unfinishedTransactions) {
            remove.attr('title', ST.t('admin.communities.manage_members.have_ongoing_transactions'));
          } else {
            remove.attr('title', ST.t('admin.communities.manage_members.only_delete_disabled'));
          }
        }
        showUpdateSuccess();
      };
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
          success: updateRowSuccess,
          error: showUpdateError,
          complete: _.debounce(showUpdateIdle, DELAY)
        });
      } else {
        this.checked = !banned;
      }
    });
  };

  var initDelete = function() {
    $(document).on("click", ".delete-member a", function(e){
      e.preventDefault();
      var deletePath = $(this).attr('href');
      $('#delete-membership-link').attr('href', deletePath);
      $('#membership-delete').lightbox_me({centered: true, closeSelector: '#close_x, #close_x1'});
    });
  };

  var initStreams = function() {
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
        var postListing = $(ev.target).parent().parent().find('.post-listing');
        if (ev.target.checked) {
          postListing.removeClass('post-listing-is-disabled');
        } else {
          postListing.addClass('post-listing-is-disabled');
        }
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
  };

  // Attach analytics click handler for CSV export
  var initAnalytics = function() {
    $(".js-users-csv-export").click(function(){
      window.ST.analytics.logEvent('admin', 'export', 'users');
    });
  };

  function updateSelectedStatus() {
    var v = [];
    $(".status-select-line input:checked").each(function(){
      v.push($(this).parent().text().trim());
    });
    if (v.length === 0) {
      v = [ST.t("admin.communities.manage_members.status_filter.all")];
    } else {
      v = [ST.t("admin.communities.manage_members.status_filter.selected_js") + v.length];
    }
    $(".status-select-button, .reset").text(v.join(", "));
  }

  function outsideClickListener(evt) {
    if (!$(evt.target).closest(".status-select-line").length) {
      $(".status-select-dropdown").hide();
      document.removeEventListener('mousedown', outsideClickListener);
    }
  }

  var initStatusFilter = function() {
    $(".status-select-button").click(function(){
      $(".status-select-dropdown").show();
      setTimeout(function() { document.addEventListener('mousedown', outsideClickListener);}, 300);
    });
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
  };

  var initPopup = function() {
    var resendConfirmation = function(e) {
      e.preventDefault();
      $('#membership-popup').trigger('close');
      showUpdateNotification();
      $.ajax({
        type: "PUT",
        url: $(this).attr('href'),
        success: showUpdateSuccess,
        error: showUpdateError,
        complete: _.debounce(showUpdateIdle, DELAY)
      });
    };
    $('.show-popup').on('click', function() {
      var contentId = $(this).data('popupContentId'),
        content = $(contentId).html();
      $('#membership-popup-content').html(content);
      $('#membership-popup-content .membership-resend-confirmation').on('click', resendConfirmation);
      $('#membership-popup').lightbox_me({centered: true, closeSelector: '#close_x, #close_x1'});
    });
  };

  initStreams();
  initAnalytics();
  initBanToggle();
  initStatusFilter();
  initPopup();
  initDelete();
};
