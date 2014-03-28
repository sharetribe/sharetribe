window.ST = window.ST || {};

/**
  Initialize range slider filter

  ## Params:

  - `selector`: Selector
  - `range`: [min, max] array
  - `start`: [startValueMin, startValueMax]
  - `labels`: [labelElementMin, labelElementMax]
  - `fields`: [inputFieldMin, inputFieldMax]
  - `decimals: boolean allow decimals
*/

window.ST.rangeFilter = function(selector, range, start, labels, fields, decimals) {
  var step = decimals ? 0.01 : 1;

  function updateLabel(el) {
    return function(val) {
      el.html(val);
    };
  }

  $(selector).noUiSlider({
    range: range,
    step: step,
    start: [start[0], start[1]],
    connect: true,
    serialization: {
      resolution: step,
      to: [
        [$(fields[0]), updateLabel($(labels[0]))],
        [$(fields[1]), updateLabel($(labels[1]))]
      ]
    }
  });
};
