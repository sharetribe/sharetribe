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
window.ST.orderManager = function(fieldMap) {
  var utils = ST.utils;

  var moveUp = createSwapFn(_.findIndex, utils.findPrevIndex);
  var moveDown = createSwapFn(utils.findNextIndex, _.findIndex);

  var eventBus = new Bacon.Bus();

  /**
    For each custom field, setup click listeners (streams, using Bacon)
  */
  fieldMap.forEach(createUpDownStreams);

  function createUpDownStreams(field) {
    var up = createClickStream(".custom-fields-action-up", field);
    var down = createClickStream(".custom-fields-action-down", field);

    var upChange = up.flatMap(moveUp);
    var downChange = down.flatMap(moveDown);

    eventBus.plug(upChange);
    eventBus.plug(downChange);
  }

  function createClickStream(selector, field) {
    return $(selector, field.element).clickE().doAction(".preventDefault").map(_.constant(field.id));
  }

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

  function add(newField) {
    fieldMap.push(newField);
    createUpDownStreams(newField);
  }

  function remove(fieldId) {
    delete fieldMap[fieldId];
  }

  return {
    add: add,
    remove: remove,
    changes: eventBus.filter(_.isObject).toProperty({order: getOrder()}).changes()
  };
}

/**
  Custom field order manager.

  Makes a POST request when order changes.
*/
window.ST.createCustomFieldOrder = function(rowSelector) {

  /**
    Fetch all custom field rows and save them to a variable
  */
  var fieldMap = $(rowSelector).map(function(id, row) {
    return { 
      id: $(row).data("field-id"),
      element: $(row)
    };
  }).get();

  function customFieldUrl(url) {
    return [window.location.pathname, url].join("/").replace("//", "/");
  }

  orderManager = window.ST.orderManager(fieldMap)

  var ajaxRequest = orderManager.changes.debounce(800).map(".order")
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
window.ST.createCustomFieldOptionOrder = function(rowSelector) {

  /**
    Fetch all custom field rows and save them to a variable
  */
  var fieldMap = $(rowSelector).map(function(id, row) {
    return { 
      id: $(row).data("field-id"),
      element: $(row),
      sortPriority: Number($(row).find(".custom-field-hidden-sort-priority").val())
    };
  }).get();

  function highestSortPriority(fieldMap) {
    return _(fieldMap)
      .map("sortPriority")
      .max()
      .value()
  }

  var nextSortPriority = (function(startValue) {
    var i = startValue;
    return function() {
      i += 1;
      return i;
    }
  })(highestSortPriority(fieldMap));

  var nextId = (function() {
    var i = 0;
    return function() {
      i += 1;
      return i;
    }
  })();

  orderManager = window.ST.orderManager(fieldMap)

  orderManager.changes.onValue(function(changedFields) {
    var up = changedFields.up;
    var down = changedFields.down;

    var upHidden = up.element.find(".custom-field-hidden-sort-priority");
    var downHidden = down.element.find(".custom-field-hidden-sort-priority");

    var newUpValue = downHidden.val();
    var newDownValue = upHidden.val();

    upHidden.val(newUpValue);
    downHidden.val(newDownValue);
  });

  var newOptionTmpl = _.template($("#new-option-tmpl").html());
  var $customFieldOptions = $("#options");

  $("#custom-fields-add-option").click(function(e) {
    e.preventDefault();
    var id = "jsnew-" + nextId();
    var newFieldEl = $(newOptionTmpl({id: id, sortPriority: nextSortPriority()}));
    $customFieldOptions.append(newFieldEl);
    var newField = {
      id: id,
      element: newFieldEl
    };
    ST.newOptionAdded();
    ST.customFieldOptionOrder.add(newField);
  });

  return {
    remove: orderManager.remove,
    add: orderManager.add
  }
};