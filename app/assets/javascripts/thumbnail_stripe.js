window.ST = window.ST || {};

ST.thumbnailStripe = function(container, elements, opts) {
  // Options
  opts = opts || {};
  var selectedClass = opts.selectedClass || "selected";
  var thumbnailWidth = opts.thumbnailWidth || 60;
  var paddingAdjustment = opts.paddingAdjustment || 0;

  // Element initialization
  container.empty();
  var visibleWidth = container.width();
  var thumbnailContainer = $("<div />");
  thumbnailContainer.css("position", "absolute");
  thumbnailContainer.css("left", ["-", paddingAdjustment, "px"].join(""));
  thumbnailContainer.css("right", ["-", paddingAdjustment, "px"].join(""));
  container.append(thumbnailContainer);
  var thumbnailContainerWidth;

  _.each(elements, function(el) {
    thumbnailContainer.append(el);
  });

  thumbnailContainerWidth = elements.length * thumbnailWidth + 2 * paddingAdjustment;
  thumbnailContainer.width(thumbnailContainerWidth);

  var maxMovement = Math.max((elements.length - Math.floor(visibleWidth / thumbnailWidth)) - 2, 0);
  var modWidth = thumbnailWidth - ((visibleWidth % thumbnailWidth) / 2) - paddingAdjustment;

  // State
  var current = 0;
  var containerMoved = 0;
  var modAdded = 0;

  var nextIndex = _.partial(ST.utils.nextIndex, elements.length);
  var prevIndex = _.partial(ST.utils.prevIndex, elements.length);

  function next() {
    var newIdx = nextIndex(current);

    if(goingRight(newIdx)) {
      if(!isPosVisible(newIdx)) {
        moveRight(newIdx);
      }
    } else {
      moveBackLeft();
    }

    activate(newIdx);
  }

  function prev() {
    var newIdx = prevIndex(current);

    if(goingLeft(newIdx)) {
      if(!isPosVisible(newIdx)) {
        moveLeft(newIdx);
      }
    } else {
      moveBackRight();
    }

    activate(newIdx);
  }

  function show(newIdx) {
    if(goingRight(newIdx) && !isPosVisible(newIdx)) {
      moveRight(newIdx);
    }

    if(goingLeft(newIdx) && !isPosVisible(newIdx)) {
      moveLeft(newIdx);
    }

    activate(newIdx);
  }

  function activate(idx) {
    var old = current;
    current = idx;
    elements[old].removeClass(selectedClass);
    elements[current].addClass(selectedClass);
  }

  function isPosVisible(idx) {
    var thumbStart = idx * thumbnailWidth;
    var thumbEnd = thumbStart + thumbnailWidth;
    var start = (containerMoved * thumbnailWidth) + (modAdded * modWidth);
    var end = start + visibleWidth;
    return start <= thumbStart && thumbEnd <= end;
  }

  function goingLeft(newIdx) {
    return newIdx < current;
  }

  function goingRight(newIdx) {
    return newIdx > current;
  }

  function moveRight(newIdx) {
    var firstMove = containerMoved == 0 && modAdded == 0;
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
    var firstMove = containerMoved == maxMovement && modAdded == 2;
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
    containerMoved = maxMovement;

    move(containerMoved, modAdded);
  }

  function move(wholeMoves, partialMoves) {
    thumbnailContainer.transition({ x: (-1 * ((wholeMoves * thumbnailWidth) + (partialMoves * modWidth)) ) });
  }

  return {
    next: next,
    prev: prev,
    show: show
  }
}