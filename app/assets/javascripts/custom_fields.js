window.ST = window.ST || {};

/**
  Almost generic order manager.

  Keeps track order of the fields and updates DOM when change happens.

  Return Bacon stream, which is triggered when ever an order change
  happens. The stream event has following payload:
  {
    down: {id: <option.id>, element: <DOM element> } // Field that went down
    up: {id: <option.id>, element: <DOM element> }, // Field that went up
    order: [<option.id>, <option.id>, <option.id> , ...] // Current order
  }
*/
window.ST.orderManager = function(rowSelector) {

  /**
    Fetch all custom field rows and save them to a variable
  */
  var customFields = $(rowSelector).map(function(id, row) {
    return { 
      id: $(row).data("field-id"),
      element: $(row)
    };
  }).get();

  /**
    Order manager is in charge of keeping and updating the field order.
    It provides three methods:

    - `up(fieldId)`: Moves up
    - `down(fieldId)`: Moves down
    - `getOrder()`: Returns array of fieldIds, in correct order
  */
  var orderManager = (function createSwapper(fieldMap, utils) {
    function swapDomElements(downEl, upEl) {
      var downDone = downEl.transition({ y: upEl.height() }).promise();
      var upDone = upEl.transition({ y: (-1) * downEl.height() }).promise();

      $.when(downDone, upDone).done(function() {
        $(downEl).before($(upEl));
        upEl.transition({y: 0, duration: 0});
        downEl.transition({y: 0, duration: 0});
      });
    }

    function swap(downId, upId) {
      var downField = fieldMap[downId];
      var upField = fieldMap[upId];

      var downEl = downField.element;
      var upEl = upField.element;

      swapDomElements(downEl, upEl);
      fieldMap = utils.swapArrayElements(fieldMap, downId, upId);

      return Bacon.once({down: downField, up: upField, order: getOrder()});
    }

    function getOrder() {
      return _.map(fieldMap, 'id');
    }

    function createSwapFn(upIdFinder, downIdFinder) {
      var byFieldId = _.curry(function(id, field) {
        return field.id == id;
      });

      return function(fieldId) {
        var upArrayId = upIdFinder(fieldMap, byFieldId(fieldId));
        var downArrayId = downIdFinder(fieldMap, byFieldId(fieldId));

        if (downArrayId >= 0 && upArrayId >= 0) {
          return swap(downArrayId, upArrayId);
        }
      }
    }

    return {
      up: createSwapFn(_.findIndex, utils.findPrevIndex),
      down: createSwapFn(utils.findNextIndex, _.findIndex),
      getOrder: getOrder
    }
  })(customFields, ST.utils);

  function clickStream(selector, field) {
    return $(selector, field.element).clickE().doAction(".preventDefault").map(_.constant(field.id));
  }

  /**
    For each custom field, setup click listeners (streams, using Bacon)
  */
  var upAndDownStreams = _.flatten(customFields.map(function(field) {

    var up = clickStream(".custom-fields-action-up", field);
    var down = clickStream(".custom-fields-action-down", field);

    var upChange = up.flatMap(orderManager.up);
    var downChange = down.flatMap(orderManager.down);

    return [upChange, downChange];
  }));

  return Bacon.mergeAll.apply(null, upAndDownStreams).filter(_.isObject).toProperty({order: orderManager.getOrder()}).changes();
}

/**
  Custom field order manager.

  Makes a POST request when order changes.
*/
window.ST.customFieldOrder = function(rowSelector) {

  function customFieldUrl(url) {
    return [window.location.pathname, url].join("/").replace("//", "/");
  }

  orderManager = window.ST.orderManager(rowSelector)

  var ajaxRequest = orderManager.debounce(800).map(".order")
    .skipDuplicates(_.isEqual)
    .map(function(order) {
    return {
      type: "POST",
      url: customFieldUrl("order"),
      data: { order: order }
    };
  });

  var ajaxResponse = ajaxRequest.ajax()
    .map(function() { return true; })
    .mapError(function() { return false; });

  ajaxRequest.onValue(function() {
    $("#custom-field-ajax-saving").show();
    $("#custom-field-ajax-error").hide();
    $("#custom-field-ajax-success").hide();
  });

  var canHideLoadingMessage = ajaxRequest.flatMapLatest(function() {
    return Bacon.later(1000, true).toProperty(false);
  }).toProperty(false);

  var isTrue = function(value) { return value === true};
  var isFalse = function(value) { return value === false};

  canHideLoadingMessage.and(ajaxResponse).filter(isTrue).onValue(function(v) {
    $("#custom-field-ajax-saving").hide();
    $("#custom-field-ajax-success").show();
  });

  canHideLoadingMessage.and(ajaxResponse.not()).filter(isTrue).onValue(function(v) {
    $("#custom-field-ajax-saving").hide();
    $("#custom-field-ajax-error").show();
  });

  canHideLoadingMessage.and(ajaxResponse).debounce(3000).onValue(function() {
    $("#custom-field-ajax-success").fadeOut();
  });
};

/**
  Custom field option order manager.

  Changes `sort_priority` hidden field when order changes.
*/
window.ST.customFieldOptionOrder = function(rowSelector) {
  orderManager = window.ST.orderManager(rowSelector)

  orderManager.onValue(function(changedFields) {
    var up = changedFields.up;
    var down = changedFields.down;

    var upHidden = up.element.find(".custom-field-hidden-sort-priority");
    var downHidden = down.element.find(".custom-field-hidden-sort-priority");

    var newUpValue = downHidden.val();
    var newDownValue = upHidden.val();

    upHidden.val(newUpValue);
    downHidden.val(newDownValue);
  });
};