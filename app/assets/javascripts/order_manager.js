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

  Params:

  fieldMap: [
    {
      id: model id,
      element: jQuery element,
      up: Up arrow jQuery element,
      down: Down arrow jQuery element
    },
    ...
  ]
*/
window.ST.orderManager = function(fieldMap) {
  var utils = ST.utils;

  var byFieldId = _.curry(function(id, field) {
    return field.id === id;
  });

  function createSwapFn(upIdFinder, downIdFinder) {

    return function(fieldId) {
      var upArrayId = upIdFinder(fieldMap, byFieldId(fieldId));
      var downArrayId = downIdFinder(fieldMap, byFieldId(fieldId));

      if (downArrayId >= 0 && upArrayId >= 0) {
        return swap(downArrayId, upArrayId);
      }
    };
  }

  function createUpDownStreams(field) {
    var up = createClickStream(field.up, field.id);
    var down = createClickStream(field.down, field.id);

    var upChange = up.flatMap(moveUp);
    var downChange = down.flatMap(moveDown);

    eventBus.plug(upChange);
    eventBus.plug(downChange);
  }

  var moveUp = createSwapFn(_.findIndex, utils.findPrevIndex);
  var moveDown = createSwapFn(utils.findNextIndex, _.findIndex);

  var eventBus = new Bacon.Bus();

  eventBus.onValue(function(change) {
    swapDomElements(change.down.element, change.up.element);
  });

  /**
    For each custom field, setup click listeners (streams, using Bacon)
  */
  fieldMap.forEach(createUpDownStreams);

  function createClickStream(el, id) {
    return el.clickE().doAction(".preventDefault").map(_.constant(id));
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

    fieldMap = utils.swapArrayElements(fieldMap, downId, upId);

    return Bacon.once({down: downField, up: upField, order: getOrder()});
  }

  function getOrder() {
    return _.map(fieldMap, 'id');
  }

  function add(newField) {
    fieldMap.push(newField);
    createUpDownStreams(newField);
  }

  function remove(fieldId) {
    fieldMap = _.reject(fieldMap, byFieldId(fieldId));
  }

  return {
    add: add,
    remove: remove,
    order: eventBus.filter(_.isObject).toProperty({order: getOrder()})
  };
};
