window.ST = window.ST || {};

ST.thumbnailStripe = function(images, opts) {
  var container = $("#thumbnail-stripe");
  var thumbnailTmpl = _.template($("#image-thumbnail-template").html());

  // Options
  opts = opts || {};
  var selectedClass = opts.selectedClass || "selected";
  var thumbnailWidth = opts.thumbnailWidth || 60;
  var paddingAdjustment = opts.paddingAdjustment || 0;
  var swipeDelay = 300;

  // Element initialization
  container.empty();
  var thumbnailContainer = $("<div />");
  thumbnailContainer.css("position", "absolute");
  thumbnailContainer.css("left", ["-", paddingAdjustment, "px"].join(""));
  thumbnailContainer.css("right", ["-", paddingAdjustment, "px"].join(""));
  container.append(thumbnailContainer);
  var thumbnailContainerWidth;

  var thumbnailClickS = [];

  var elements = _.map(images, function(image, idx) {
    var thumbnailElement = $(thumbnailTmpl({url: image.images.thumb }));
    thumbnailClickS.push(thumbnailElement.asEventStream("click").map(function() { return idx; }));
    return thumbnailElement;
  });

  var clickS = Bacon.mergeAll.apply(null, thumbnailClickS).debounceImmediate(swipeDelay);

  _.each(elements, function(el) {
    thumbnailContainer.append(el);
  });

  if(elements.length < 2) {
    container.hide();
  }

  thumbnailContainerWidth = elements.length * thumbnailWidth + 2 * paddingAdjustment;
  thumbnailContainer.width(thumbnailContainerWidth);

  // State
  var initialIdx = 0;
  var containerMoved = 0;
  var modAdded = 0;

  var nextId = _.partial(ST.utils.nextIndex, elements.length);
  var prevId = _.partial(ST.utils.prevIndex, elements.length);

  var nextBus = new Bacon.Bus();
  var prevBus = new Bacon.Bus();

  elements[initialIdx].addClass(selectedClass);

  function visibleWidth() {
    return container.width();
  }

  function maxMovement() {
    return Math.max((elements.length - Math.floor(visibleWidth() / thumbnailWidth)) - 2, 0);
  }

  function modWidth() {
    return thumbnailWidth - ((visibleWidth() % thumbnailWidth) / 2) - paddingAdjustment;
  }

  function show(oldValue, newValue) {
    var oldIdx = oldValue.value;
    var newIdx = newValue.value;
    var goingLeft = oldIdx > newIdx;
    var goingRight = oldIdx < newIdx;
    var goingLeftAround = newValue.direction === "prev" && goingRight;
    var goingRightAround = newValue.direction === "next" && goingLeft;

    // Move
    if(!isPosVisible(newIdx)) {
      if(goingRight) {
        if(goingLeftAround) {
          moveBackRight();
        } else {
          moveRight(newIdx);
        }
      } else {
        if(goingRightAround) {
          moveBackLeft();
        } else {
          moveLeft(newIdx);
        }
      }
    }

    // Highlight
    elements[oldIdx].removeClass(selectedClass);
    elements[newIdx].addClass(selectedClass);
  }

  function isPosVisible(idx) {
    var thumbStart = idx * thumbnailWidth;
    var thumbEnd = thumbStart + thumbnailWidth;
    var start = (containerMoved * thumbnailWidth) + (modAdded * modWidth());
    var end = start + visibleWidth();
    return start <= thumbStart && thumbEnd <= end;
  }

  function moveRight(newIdx) {
    var firstMove = containerMoved === 0 && modAdded === 0;
    var lastMove = newIdx === elements.length - 1;

    if(lastMove) {
      modAdded = 2;
    } else if(firstMove) {
      modAdded = 1;
    } else {
      containerMoved++;
    }

    move(containerMoved, modAdded);
  }

  function moveLeft(newIdx) {
    var firstMove = containerMoved === maxMovement() && modAdded === 2;
    var lastMove = newIdx === 0;

    if(lastMove) {
      modAdded = 0;
    } else if(firstMove) {
      modAdded = 1;
    } else {
      containerMoved--;
    }

    move(containerMoved, modAdded);
  }

  function moveBackLeft() {
    modAdded = 0;
    containerMoved = 0;

    move(containerMoved, modAdded);
  }

  function moveBackRight() {
    modAdded = 2;
    containerMoved = maxMovement();

    move(containerMoved, modAdded);
  }

  function move(wholeMoves, partialMoves) {
    thumbnailContainer.transition({ x: (-1 * ((wholeMoves * thumbnailWidth) + (partialMoves * modWidth())) ) });
  }

  // Prev/Next events
  var prevIdxStream = prevBus.map(function() { return {value: null, fn: prevId, direction: "prev"}; });
  var nextIdxStream = nextBus.map(function() { return {value: null, fn: nextId, direction: "next"}; });
  var showIdxStream = clickS.map(function(newIdx) { return {value: newIdx }; });

  var idxStream = prevIdxStream.merge(nextIdxStream).merge(showIdxStream).scan({value: initialIdx}, function(a, b) {
    var newIdx = b.value != null ? b.value : b.fn(a.value);
    return {direction: b.direction, value: newIdx};
  }).skipDuplicates(_.isEqual).slidingWindow(2, 2);

  idxStream.onValues(show);

  return {
    next: function(nextStream) {
      nextBus.plug(nextStream.debounceImmediate(swipeDelay));
    },
    prev: function(prevStream) {
      prevBus.plug(prevStream.debounceImmediate(swipeDelay));
    },
    show: clickS
  };
};