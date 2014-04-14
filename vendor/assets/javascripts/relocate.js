/**
 * Use relocat() to move HTML elements in the DOM
 * above a certain window width.
 *
 * Copyright by Eike Send, Edenspiekermann AG
 *
 * Licensed under the GPLv2 and the MIT license
 *
 */

relocate = function(width, elements, destinationElement, desktopFirst) {
  // ensure that we use an array-like argument, NodeList and HTMLCollection work as well
  if (elements.nodeName) elements = [elements];
  var placeHolders = [],
      els = [],
      parentEl, el, i,
      l = elements.length;
  // first, create a non-live copy of the elements
  // this avoids nasty bugs when elements are removed and added again
  for (i = l-1; i >= 0; i--) {
    els.push(elements[i]);
  }
  var forwardFunction = function() {
    for (i = 0; i < l; i++) {
      parentEl = els[i].parentNode;
      if (placeHolders[i] === undefined) {
        placeHolders[i] = document.createElement("span");
        parentEl.insertBefore(placeHolders[i], els[i]);
      }
      el = parentEl.removeChild(els[i]);
      destinationElement.insertBefore(el, destinationElement.firstChild);
    }
  }
  var backwardFunction = function() {
    for (i = 0; i < l; i++) {
      parentEl = els[i].parentNode;
      el = parentEl.removeChild(els[i]);
      placeHolders[i].parentNode.insertBefore(el, placeHolders[i]);
    }
  }
  // then create a object that operates on it:
  if (!desktopFirst) {
    minwidth(width, forwardFunction, backwardFunction);
  } else {
    minwidth(width, backwardFunction, forwardFunction, desktopFirst);
  }
}