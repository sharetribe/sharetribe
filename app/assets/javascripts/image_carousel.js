window.ST = window.ST || {};

ST.imageCarousel = function(images, currentImageId) {
  var tmpl = _.template($("#image-frame-template").html());
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

  _.each(elements, function(el) {
    el.hide();
    container.append(el);
  });

  elements[currentIdx].show();

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

  var swipeDelay = 400;

  function swipeRight(newElement, oldElement) {
    newElement.transition({ x: -1 * newElement.width() }, 0);
    newElement.show();

    var oldDone = oldElement.transition({ x: oldElement.width() }, swipeDelay).promise();
    var newDone = newElement.transition({ x: 0 }, swipeDelay).promise();

    var bothDone = $.when(newDone, oldDone)
    bothDone.done(function() {
      oldElement.hide();
    });

    return bothDone;
  }

  function swipeLeft(newElement, oldElement) {
    newElement.transition({ x: newElement.width() }, 0);
    newElement.show();
    var oldDone = oldElement.transition({ x: -1 * oldElement.width() }, swipeDelay).promise();
    var newDone = newElement.transition({ x: 0 }, swipeDelay).promise();

    var bothDone = $.when(newDone, oldDone)
    bothDone.done(function() {
      oldElement.hide();
    });

    return bothDone;
  }

  function show(idx) {
    var goingRight = idx > currentIdx;
    var goingLeft = idx < currentIdx;

    var oldElement = elements[currentIdx];
    currentIdx = idx;
    var newElement = elements[currentIdx];

    if(goingRight) {
      swipeLeft(newElement, oldElement);
    }
    if(goingLeft) {
      swipeRight(newElement, oldElement);
    }
  }

  // Prev/Next events

  var prev = leftLink.asEventStream("click").doAction(".preventDefault").debounceImmediate(swipeDelay);
  var next = rightLink.asEventStream("click").doAction(".preventDefault").debounceImmediate(swipeDelay);

  prev.onValue(function() {
    var oldElement = elements[currentIdx];
    currentIdx = prevId(currentIdx, elements.length);
    var newElement = elements[currentIdx];

    swipeRight(newElement, oldElement);
  });

  next.onValue(function() {
    var oldElement = elements[currentIdx];
    currentIdx = nextId(currentIdx, elements.length);
    var newElement = elements[currentIdx];

    swipeLeft(newElement, oldElement);
  });

  // Returns

  return {
    prev: prev,
    next: next,
    show: show
  }
}