window.ST = window.ST || {};

/**
  Use translations in JavaScript

  Usage:

  ### Load the translations you need:

  ```haml
  = js_t(["admin.categories.new", "admin.categories.edit"])
  ```

  ### Use loaded translations

  ```javascript
  $('#new-link').text(ST.t("admin.categories.new"))
  $('#new-link').text(ST.t("admin.categories.edit"))
  ```
*/
(function(exports) {

  var store = {};

  exports.t = function(key, opts) {
    if(store[key] == null) {
      throw new Error("No translation loaded: " + key);
    }

    return _.template(store[key], opts || {});
  };

  exports.loadTranslations = function(translations) {
    _.extend(store, translations);
  };

})(window.ST);
