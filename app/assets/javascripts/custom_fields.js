$(function() {
  function idFromRow($row) {
    return $row.data("field-id");
  }

  var customFields = $(".custom-field-list-row").map(function(id, row) {
    var $row = $(row);
    return { 
      id: idFromRow($row),
      element: $row
    };
  }).get();

  var orderManager = (function createSwapper(fieldMap, utils) {
    function swapDomElements(downEl, upEl) {
      $(downEl).before($(upEl));
    }

    function swap(downId, upId) {
      var downEl = fieldMap[downId].element;
      var upEl = fieldMap[upId].element;

      swapDomElements(downEl, upEl);
      fieldMap = utils.swapArrayElements(fieldMap, downId, upId);
    }

    function createSwapFn(upIdFinder, downIdFinder) {
      var byFieldId = _.curry(function(id, field) {
        return field.id == id;
      });

      return function(fieldId) {
        var upArrayId = upIdFinder(fieldMap, byFieldId(fieldId));
        var downArrayId = downIdFinder(fieldMap, byFieldId(fieldId));

        if (downArrayId >= 0 && upArrayId >= 0) {
          swap(downArrayId, upArrayId);
        }
      }
    }

    return {
      up: createSwapFn(_.findIndex, utils.findPrevIndex),
      down: createSwapFn(utils.findNextIndex, _.findIndex),
      getOrder: function() {
        return _.map(fieldMap, 'id');
      }
    }
  })(customFields, ST.utils);

  customFields.forEach(function(field) {

    function customFieldUrl(url) {
      return [window.location.pathname, url].join("/").replace("//", "/");
    }

    function clickStream(selector, $container, id) {
      return $(selector, field.element).clickE().doAction(".preventDefault").map(_.constant(field.id));
    }

    var up = clickStream(".custom-fields-action-up");
    var down = clickStream(".custom-fields-action-down");

    up.onValue(orderManager.up);
    down.onValue(orderManager.down);

    var ajaxRequest = up.merge(down).debounce(500).map(function() {
      return {
        type: "POST",
        url: customFieldUrl("order"),
        data: {order: orderManager.getOrder() }
      };
    });

    var ajaxResponse = ajaxRequest.ajax();
    var ajaxStatus = ajaxResponse
      .map(function() { return true; })
      .mapError(function() { return false; });

    ajaxRequest.onValue(function() {
      $("#custom-field-ajax-saving").show();
      $("#custom-field-ajax-error").hide();
      $("#custom-field-ajax-success").hide();
    });

    ajaxStatus.onValue(function(success) {
      $("#custom-field-ajax-saving").hide();
      if(success) {
        $("#custom-field-ajax-success").show();
      } else {
        $("#custom-field-ajax-error").show();
      }
    });

    var hideSuccessMessage = ajaxStatus.filter(true).throttle(3000);
    hideSuccessMessage.onValue(function() {
      $("#custom-field-ajax-success").hide();
    });
  });
});