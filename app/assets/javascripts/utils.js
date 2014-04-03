window.ST = window.ST || {};

ST.utils = (function(_) {

  function findNextIndex(arr, fn) {
    if(arr.length < 2) {
      return -1;
    } else {
      var idx = _.findIndex(arr, fn);
      return idx !== -1 && idx < arr.length - 1 ? idx + 1 : -1;
    }
  }

  function findPrevIndex(arr, fn) {
    if (arr.length < 2) {
      return -1;
    } else {
      var idx = _.findIndex(arr, fn);
      return idx !== -1 && idx > 0 ? idx - 1 : -1;
    }
  }

  /**
    Give `current` index and array `length` and get back
    next index or first index
  */
  function nextIndex(length, current) {
    return (current + 1) % length;
  }

  /**
    Give `current` index and array `length` and get back
    prev index or last index
  */
  function prevIndex(length, current) {
    return current === 0 ? length - 1 : current - 1;
  }

  function swapArrayElements(arr, idx1, idx2, deep) {
    deep = deep || false;

    var newArr = _.clone(arr, deep);
    newArr[idx1] = arr[idx2];
    newArr[idx2] = arr[idx1];
    return newArr;
  }

  /**
    Create relative URLs.

    ## Usage:

    If you're in 'http://market.sharetribe.com/admin/categories/' then

    ```
      console.log(relativeUrl("order/14")) // -> 'http://market.sharetribe.com/admin/categories/order/15'
    ```
  */
  function relativeUrl(url) {
    return [window.location.pathname, url].join("/").replace("//", "/");
  }

  /**
    Give attribute value and get back jqueryfied version that
    can be used as a part of a selector

    Example:

    var jquerified = jquerifyAttributeValue("person[name]") // => "person\[name\]"
    nameInput = $("[name=" + jquerified + "]");
  */
  function jquerifyAttributeValue(attrValue) {
    return attrValue.replace(/\[/g, "\\[").replace(/\]/g, "\\]");
  }

  /**
    Give element `name` attribute value and get back matching elements

    Example:
    <input name="plaaplaa">

    var plaaplaa = findElementByName("plaaplaa") // => jQuery element

  */
  function findElementByName(name) {
    var selector = ["[name=", jquerifyAttributeValue(name), "]"].join("");
    return $(selector);
  }

  /**
    Give an array of objects and get back one merged object.

    ## Usage:

    objectsMerge([{a: 1, b: 2}, {c: 3}, {d: 4}]) => {a: 1, b: 2, c: 3, d: 4}
  */
  function objectsMerge(objects) {
    return objects.reduce(function(a, b) {
      return _.merge(a, b);
    }, {});
  }

  function not(fn) {
    return function() {
      return !fn.apply(null, arguments);
    }
  }

  function baconStreamFromAjaxPolling(ajaxOpts, predicate) {
    return Bacon.fromBinder(function(sink) {
      function poll() {
        var ajax = Bacon.once(ajaxOpts).ajax()

        ajax.filter(predicate).onValue(function(statusResult) {
          sink([new Bacon.Next(statusResult), new Bacon.End()]);
        });

        ajax.filter(not(predicate)).onValue(function() {
          _.delay(poll, 1000);
        });

        ajax.onError(function(e) {
          sink([new Bacon.Error(e), new Bacon.End()]);
        })
      }

      poll();

      return _.identity; // No-op unsubscripbe function
    });
  }

  /**
    Give filename and get back extension
  */
  function fileExtension(filename) {
    return _.last(filename.split("."));
  }

  /**
    Give filename and get back content type
  */
  function contentTypeByFilename(filename) {
    var map = {
      "jpg": "image/jpeg",
      "jpeg": "image/jpeg",
      "png": "image/png",
      "gif": "image/gif",
    };

    return map[fileExtension(filename)];
  }

  return {
    findNextIndex: findNextIndex,
    findPrevIndex: findPrevIndex,
    nextIndex: nextIndex,
    prevIndex: prevIndex,
    swapArrayElements: swapArrayElements,
    relativeUrl: relativeUrl,
    jquerifyAttributeValue: jquerifyAttributeValue,
    findElementByName: findElementByName,
    objectsMerge: objectsMerge,
    baconStreamFromAjaxPolling: baconStreamFromAjaxPolling,
    contentTypeByFilename: contentTypeByFilename
  };

})(_);
