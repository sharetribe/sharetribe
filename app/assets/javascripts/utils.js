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

  return {
    findNextIndex: findNextIndex,
    findPrevIndex: findPrevIndex,
    swapArrayElements: swapArrayElements,
    relativeUrl: relativeUrl,
    jquerifyAttributeValue: jquerifyAttributeValue,
    findElementByName: findElementByName,
    objectsMerge: objectsMerge
  };

})(_);
