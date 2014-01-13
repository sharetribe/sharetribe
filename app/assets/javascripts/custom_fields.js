$(function() {
  function idFromRow($row) {
    return $row.data("field-id");
  }

  function clickStream(selector, $container, id) {
    var $el = $(selector, $container);
    return $el.asEventStream("click").doAction(".preventDefault");
  }

  var customFields = $(".custom-field-list-row").map(function(id, row) {
    var $row = $(row);
    return { 
      id: idFromRow($row),
      element: $row
    };
  }).get();

  var swapper = (function createSwapper(fieldMap) {
    function getById(id) {
      // USE UNDERSCORE FIND
      return fieldMap.reduce(function(a, b) {
        return b.id === id ? b : a;
      }, null)
    }

    function swapElements(down, up) {
      var downEl = getById(down).element;
      var upEl = getById(up).element;

      $(downEl).before($(upEl));
    }

    function pushSecondLast(arr, item) {
      var curLastIdx = arr.length - 1;
      var newLastIdx = arr.length;
      arr[newLastIdx] = arr[curLastIdx];
      arr[curLastIdx] = item;
      return arr;
    }

    function swapArray(down, up) {
      debugger;
      fieldMap = fieldMap.reduce(function(arr, item) {
        return item.id === up ? pushSecondLast(arr, item) : arr.concat([item])
      }, []);
    }

    function findBefore(arr, id) {
      var prev;
      var found;
      arr.forEach(function(item) {
        if(item.id === id) {
          found = prev.id;
        } else {
          prev = item;
        }
      });
      return found;
    }

    function findNext(arr, id) {
      var prev;
      var found;
      arr.forEach(function(item) {
        if(prev && prev.id === id) {
          found = item.id;
        } else {
          prev = item;
        }
      });
      return found;
    }

    function up(upId) {
      var downId = findBefore(fieldMap, upId);

      swapElements(downId, upId);
      swapArray(downId, upId);
    }

    function down(downId) {
      var upId = findNext(fieldMap, downId);
      swapElements(downId, upId);
      swapArray(downId, upId);
    }

    return {
      up: up,
      down: down
    }
  })(customFields);

  customFields.forEach(function(field) {
    var up = clickStream(".custom-fields-action-up", field.element).map(function() {
      return field.id;
    });
    var down = clickStream(".custom-fields-action-down", field.element).map(function() {
      return field.id;
    });

    up.onValue(swapper.up);
    down.onValue(swapper.down);
  });
});