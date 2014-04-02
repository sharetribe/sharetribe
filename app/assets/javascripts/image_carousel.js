window.ST = window.ST || {};

ST.thumbnailStripe = function(container, elements, opts) {
  // Options
  opts = opts || {};
  var selectedClass = opts.selectedClass || "selected";
  var thumbnailWidth = opts.thumbnailWidth || 60;

  // Element initialization
  container.empty();
  var visibleWidth = container.width();
  var thumbnailContainer = $("<div />");
  container.append(thumbnailContainer);
  var thumbnailContainerWidth;

  _.each(elements, function(el) {
    thumbnailContainer.append(el);
  });

  thumbnailContainerWidth = elements.length * thumbnailWidth;
  thumbnailContainer.width(thumbnailContainerWidth);

  var modWidth = (thumbnailWidth - (visibleWidth % thumbnailWidth)) / 2;

  // State
  var current;
  var containerMoved = 0;
  var modAdded = 0;

  function next() {
    var newIdx = (current + 1) % elements.length;
    var goingAround = newIdx === 0;

    if(goingRight(newIdx) && !isPosVisible(newIdx)) {
      moveRight();
    }

    if(goingAround) {
      moveBackLeft();
    }

    activate(newIdx);
  }

  function prev() {
    var newIdx = (current - 1) >= 0 ? (current - 1) : elements.length - 1;
    var goingAround = newIdx == elements.length - 1;

    if(goingLeft(newIdx) && !isPosVisible(newIdx)) {
      moveLeft();
    }

    if(goingAround) {
      moveBackRight();
    }

    activate(newIdx);
  }

  function show(newIdx) {

    if(goingRight(newIdx) && !isPosVisible(newIdx)) {
      moveRight();
    }

    if(goingLeft(newIdx) && !isPosVisible(newIdx)) {
      moveLeft();
    }

    activate(newIdx);
  }

  function activate(idx) {
    var old = current;
    current = idx;

    if(old != null) {
      elements[old].removeClass(selectedClass);
    }

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

  function goingBackRight() {

  }

  function goingBackLeft() {

  }

  function firstMoveLeft(currentIdx, newIdx) {

  }

  function lastMoveLeft(currentIdx, newIdx) {

  }

  function firstMoveRight(currentIdx, newIdx) {

  }

  function firstMoveRight(currentIdx, newIdx) {

  }

  function moveRight() {
    var firstMove = containerMoved == 0;
    var lastMove = current + 1 === elements.length - 1;

    if(lastMove) {
      modAdded = 2;
      move(containerMoved, 2);
    } else {
      containerMoved++;
      modAdded = 1;
      move(containerMoved, 1);
    }
  }

  function moveLeft() {
    var firstMove = current - 1 === elements.length - 2;
    var lastMove = current - 1 === 0;

    if(lastMove) {
      modAdded = 0;
      move(containerMoved, 0);
    } else {
      containerMoved--;
      modAdded = 1;
      move(containerMoved, 1);
    }
  }

  function moveBackLeft() {
    modAdded = 0;
    containerMoved = 0;
    move(0, 0);
  }

  function moveBackRight() {
    modAdded = 2;
    var maxMovements = (elements.length - Math.floor(visibleWidth / thumbnailWidth)) - 1;
    containerMoved = Math.max(maxMovements, 0);
    move(containerMoved, 2)
  }

  function move(wholeMoves, partialMoves) {
    thumbnailContainer.transition({ x: (-1 * ((wholeMoves * thumbnailWidth) + (partialMoves * modWidth)) ) });
  }

  return {
    next: next,
    prev: prev,
    show: show,
  }
}

ST.imageCarousel = function(images, currentImageId) {
  var tmpl = _.template($("#image-frame-template").html());
  var thumbnailTmpl = _.template($("#image-thumbnail-template").html());
  var leftLink = $("#listing-image-navi-left");
  var rightLink = $("#listing-image-navi-right");
  var container = $("#listing-image-frame");
  var thumbnailContainer = $("#listing-image-thumbnails");
  var thumbnailOverflow = $("#listing-image-thumbnails-mask");

  var imageIds = _(images).map(function(image) { return image.id }).value();
  var currentIdx = _.indexOf(imageIds, currentImageId);

  var elements = _.map(images, function(image) {
    return $(tmpl({url: image.images.big, aspectRatioClass: image.aspectRatio }));
  });

  var thumbnails = _.map(images, function(image) {
    return $(thumbnailTmpl({url: image.images.thumb }));
  });

  _.each(elements, function(el) {
    el.hide();
    container.append(el);
  });

  _.each(thumbnails, function(el) {
    thumbnailContainer.append(el);
  })

  elements[currentIdx].show();
  thumbnails[currentIdx].addClass("selected");

  var thumbnailWidth = thumbnails[0].width();

  thumbnailContainer.width(thumbnailWidth * thumbnails.length);

  function prevId(currId, length) {
    if (currId === 0) {
      return length - 1;
    } else {
      return currId - 1
    }
  }

  function nextId(currId, length) {
    return (currId + 1) % length;
  }

  leftLink.asEventStream("click").doAction(".preventDefault").onValue(function() {
    var visibleWidth = thumbnailOverflow.width();

    thumbnails[currentIdx].removeClass("selected");
    var oldElement = elements[currentIdx];

    currentIdx = prevId(currentIdx, elements.length);

    var thumbnailPos = thumbnailWidth * currentIdx;

    if((visibleWidth - thumbnailPos) < thumbnailWidth) {
      thumbnailsMoved--;
      thumbnailContainer.transition({ x: (-1 * thumbnailsMoved * thumbnailWidth) });
    }

    thumbnails[currentIdx].addClass("selected");
    var newElement = elements[currentIdx];

    newElement.transition({ x: -1 * newElement.width() }, 0);
    newElement.show();
    var newDone = newElement.transition({ x: 0 }).promise();
    var oldDone = oldElement.transition({ x: newElement.width() }).promise();

    $.when(newDone, oldDone).done(function() {
      oldElement.hide();
    });
  });

  thumbnailsMoved = 0;

  rightLink.asEventStream("click").doAction(".preventDefault").onValue(function() {
    var visibleWidth = thumbnailOverflow.width();

    thumbnails[currentIdx].removeClass("selected");
    var oldElement = elements[currentIdx];

    currentIdx = nextId(currentIdx, elements.length);

    var thumbnailPos = thumbnailWidth * currentIdx;

    if((visibleWidth - thumbnailPos) < thumbnailWidth) {
      thumbnailsMoved++;
      thumbnailContainer.transition({ x: (-1 * thumbnailsMoved * thumbnailWidth) });
    }

    thumbnails[currentIdx].addClass("selected");
    var newElement = elements[currentIdx];

    newElement.transition({ x: newElement.width() }, 0);
    newElement.show();
    var newDone = newElement.transition({ x: 0 }).promise();
    var oldDone = oldElement.transition({ x: -1 * newElement.width() }).promise();

    $.when(newDone, oldDone).done(function() {
      oldElement.hide();
    });

  });
}