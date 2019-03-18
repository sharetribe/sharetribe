// this shim is to fix IE & Firefox's problem where
// getComputedStyle(<element>).cssText returns an empty string rather than a
// string of computed CSS styles for the element
if (typeof navigator !== "undefined" && navigator.userAgent.match(/msie|windows|firefox/i)) {
  Node.prototype.getComputedCSSText = function() {
    var s = [];
    var cssTranslation = { "cssFloat": "float" }
    var computedStyle = document.defaultView.getComputedStyle(this);
    for (var propertyName in computedStyle) {
      if ("string" == typeof(computedStyle[propertyName]) &&
       computedStyle[propertyName] != "") {
        var translatedName = cssTranslation[propertyName] || propertyName;
        s[s.length] = (translatedName.replace(/[A-Z]/g, function(x) {
              return "-" + (x.toLowerCase())
            })) + ": " + computedStyle[propertyName];
      }
    }

    return s.join('; ') + ";";
  };
}
