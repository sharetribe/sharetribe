window.ST = window.ST || {};

(function(exports) {

  /**
   * Adds radiobutton functionality
   *
   * Usage:
   *
   * - create an `input` tag
   * - create two or more buttons
   * - invoke initializeRadioButtons
   *
   * Input tag:
   *
   * The selected value will be added to the `input` element. There's no special
   * requirements for the input element. It has to have a unique selector
   * (prefer classes over ids)
   *
   * Buttons:
   *
   * Button needs to contain data attribute `radio-button-value`. The attribute
   * value will be copied to the `input` element when selected. Also, a class
   * `radio-button-selected` will be added to the button when it's selected.
   *
   * Parameters:
   *
   * - buttonSelectors: array of button selectors
   * - inputSelector: selector for the input element
   *
   */

  var SELECTED_CLASS = "radio-button-selected";
  var DATA_ATTR_NAME = "radio-button-value";

  var select = function(selectedButton, input, buttons) {
    var selectedButtonEl = selectedButton.element;
    input.val(selectedButtonEl.data(DATA_ATTR_NAME));

    buttons.forEach(function(button) {
      var buttonEl = button.element;

      if (buttonEl.is(selectedButtonEl)) {
        buttonEl.addClass(SELECTED_CLASS);
      } else {
        buttonEl.removeClass(SELECTED_CLASS);
      }
    });
  };

  var initializeButton = function(buttonSelector) {
    return {
      selector: buttonSelector,
      element: $(buttonSelector)
    };
  };

  var initialize = function(opts) {
    opts = opts || {};

    var buttonSelectors  = opts.buttons;
    var inputSelector    = opts.input;
    var callback         = opts.callback || function() {};

    var input = $(inputSelector);
    var buttons = buttonSelectors.map(initializeButton);

    buttons.forEach(function(button) {
      button.element.click(function() {
        select(button, input, buttons);
        callback(button.selector, button.element);
      });
    });
  };

  exports.initializeRadioButtons = initialize;

})(window.ST);
