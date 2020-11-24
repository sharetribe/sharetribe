/**
  This is a Sharetribe modified version of minwidth.js function: https://github.com/edenspiekermann/minwidth-relocate/

  ### Why modified version?

  The original version didn't include scrollbars to the width, thus being inconsistent with
  CSS media queries.

  In this version `getWindowWidth` uses window.innerWidth, which is not supported in IE < 9

*/

/**
 * Use minwidth() to bind callbacks to changes of
 * the window width or a minimum width at page load.
 *
 * Copyright by Eike Send, Edenspiekermann AG
 *
 * Licensed under the GPLv2 and the MIT license
 *
 */

(function(win){
  var getWindowWidth = function() {
    // Get window width, code adapted from jQuery
    if ('innerWidth' in win) {
      return win.innerWidth;
    } else {
      var docwindowProp = doc.documentElement["clientWidth"];
      return doc.compatMode === "CSS1Compat" && docwindowProp
             || doc.body && doc.body["clientWidth"]
             || docwindowProp;
    }
  }

  var doc = win.document,
      instances = [],
      oldWidth = 0,
      windowWidth = getWindowWidth();

  var resizeCallback = function() {
    windowWidth = getWindowWidth();
    var i, instance;
    for (i = 0; i < instances.length; i++) {
      instance = instances[i];
      // Check Forward:
      if (instance.old < instance.wdt &&
          windowWidth >= instance.wdt &&
          instance.fwd) {
        instance.fwd();
      }
      // Check Backward:
      if (instance.old >= instance.wdt &&
          windowWidth < instance.wdt &&
          instance.bck) {
        instance.bck();
      }
      instance.old = windowWidth;
    }
  }

  if (win.addEventListener) {
    win.addEventListener("resize", resizeCallback, false);
  } else {
    win.attachEvent("onresize", resizeCallback);
  }

  // This is the function that is exported into the global namespace
  // The paramaters are:
  // * the width at which the callbacks are called
  // * the callback going from below to above the width, this is
  //   initially called if the screen width is wider that "width"
  // * the callback going back from above the width to below it
  // * if the fourth paramater is passed as "true", the forward callback
  //   is initally not called, but the backward callback is called
  //   if the screenwidth is smaller than width.
  win.minwidth = function(width, forwardCallback, backwardCallback, desktopFirst) {
    instances.push({
      wdt: width,
      old: desktopFirst ? 1E9 : 0,
      fwd: forwardCallback,
      bck: backwardCallback
    });
    resizeCallback();
  }

})(this);