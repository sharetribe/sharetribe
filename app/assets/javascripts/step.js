import debounce from 'lodash.debounce';
import Tooltip from './tooltip';
import Constants from './constants';
import Style from './style';

let MAX_ATTEMPTS = 100;
let DOM_QUERY_DELAY = 100;

let Promise = require('es6-promise').Promise;

class Step {

  /** The step configuration is where you specify which elements of the page
   * will be cloned and placed over the overlay. These elements are the
   * what appear as highlighted to the user.
   *
   * @typedef StepConfiguration
   * @property {TooltipConfiguration} tooltip - Tooltip configuration.
   * @property {Object.<string, string>|string[]|string} [selectors] -
   *  Object with arbitrarily-named keys and CSS selector values.
   *  These keys can then be referenced from <code>TooltipConfiguration.anchorElement.</code>
   *  Or, an array of selector strings if named keys are not required.
   *  Or, a string if only one selector is required.<br/>
   *  Notes: Specifying a selector that targets another specified selector
   *  will result in unpredictable behavior.<br/>
   *  Specifying multiple selectors will effectively cause
   *  <code>Tutorial.useTransparentOverlayStrategy == false.</code>
   */

  /**
   * @constructor
   * @param {StepConfiguration} config - The configuration for this step
   * @param {integer} index - The index of this step within the current tutorial
   * @param {Tutorial} tutorial - The Tutorial object corresponding to this Step
   * @param {Overlay} overlay - The Overlay object displayed along with this
   *  Step
   * @param {ChariotDelegate} [delegate] - An optional delegate that responds to
   *  lifecycle callbacks
   */
  constructor(config = {}, index, tutorial, overlay, delegate) {
    this.tutorial = tutorial;
    this.index = index;
    this.overlay = overlay;
    this.delegate = delegate || {};

    if (!config.selectors) {
      throw new Error('selectors must be present in Step configuration\n' +
        this);
    } else if (typeof config.selectors === 'string') {
      this.selectors = { 0: config.selectors };
    } else if (Object.prototype.toString.call(config.selectors) === '[object Object]') {
      if (!Object.keys(config.selectors).length) {
        throw new Error('selectors must be present in Step configuration\n' +
          this);
      }
      this.selectors = config.selectors;
    } else if (Array.isArray(config.selectors)) {
      const selectorsMap = {};
      config.selectors.forEach((val, idx) => {
        selectorsMap[idx] = val;
      });
      this.selectors = selectorsMap;
    } else {
      throw new Error('selectors must be an object, array, or string');
    }

    this._resizeTimeout = null;

    this._elementMap = {};
    for (let selectorName in this.selectors) {
      this._elementMap[selectorName] = {};
    }

    this.tooltip = new Tooltip(config.tooltip, this, tutorial);
  }

  render() {
    Promise.resolve().then(() => {
      if (this.delegate.willBeginStep) {
        return this.delegate.willBeginStep(
          this, this.index, this.tutorial);
      }
    }).then(() => {
      if (this.delegate.willShowOverlay) {
        return this.delegate.willShowOverlay(
          this.overlay, this.index, this.tutorial);
      }
    }).then(() => {
      // Show a temporary background overlay while we wait for elements
      this.overlay.showBackgroundOverlay();
      return this._waitForElements();
    }).then(() => {
      // Render the overlay
      if (this.overlay.isTransparentOverlayStrategy() &&
          Object.keys(this.selectors).length === 1) {
        this._singleTransparentOverlayStrategy();
      } else {
        this._clonedElementStrategy();
      }
    }).then(() => {
      if (this.delegate.didShowOverlay) {
        return this.delegate.didShowOverlay(
          this.overlay, this.index, this.tutorial);
      }
    }).then(() => {
      if (this.delegate.willRenderTooltip) {
        return this.delegate.willRenderTooltip(
          this.tooltip, this.index, this.tutorial);
      }
    }).then(() => {
      this._renderTooltip();
      if (this.delegate.didRenderTooltip) {
        return this.delegate.didRenderTooltip(
          this.tooltip, this.index, this.tutorial);
      }
    }).then(() => {
      // Resize the overlay in case the tooltip extended the width/height of DOM
      this.overlay.resize();

      // Setup resize handler
      this._resizeHandler = debounce(() => {
        for (let selectorName in this.selectors) {
          let elementInfo = this._elementMap[selectorName];
          if (elementInfo.clone) {
            let $element = elementInfo.element;
            let $clone = elementInfo.clone;
            Style.clearCachedStylesForElement($element);
            this._applyComputedStyles($clone, $element);
            this._positionClone($clone, $element);
          }
        }
        this.tooltip.reposition();
        this.overlay.resize();
      }, 50);
      $(window).on('resize', this._resizeHandler);
    }).catch(error => {
      console.log(error);
      this.tutorial.tearDown();
    });
  }

  _moveTo(action) {
    Promise.resolve().then(() => {
      if (this.delegate.didFinishStep) {
        return this.delegate.didFinishStep(
          this, this.index, this.tutorial);
      }
    }).then(() => {
      action();
    }).catch(error => {
      console.log(error);
      action();
    });
  }

  previous() {
    this._moveTo(() => this.tutorial.next(this.index - 1));
  }

  next() {
    this._moveTo(() => this.tutorial.next());
  }

  getClonedElement(selectorName) {
    let elementInfo = this._elementMap[selectorName];
    if (!elementInfo) return;
    return elementInfo.clone;
  }

  tearDown() {
    let $window = $(window);
    for (let selectorName in this.selectors) {
      let selector = this.selectors[selectorName]
      // Remove computed styles
      Style.clearCachedStylesForElement($(selector));
      let elementInfo = this._elementMap[selectorName];
      if (elementInfo.clone) {
        // Remove cloned elements
        elementInfo.clone.remove();
      }
    }
    this.tooltip.tearDown();

    $window.off('resize', this._resizeHandler);
  }

  prepare() {
    // FIX: This method currently always prepares for the clone strategy,
    // regardless of the value of useTransparentOverlayStrategy.
    // Perhaps add a check or rename this method, once the coupling to
    // this.tutorial.prepare() is removed
    for (let selectorName in this.selectors) {
      let selector = this.selectors[selectorName]
      this._computeStyles($(selector));
    }
  }

  toString() {
    return `[Step - index: ${this.index}, ` +
      `selectors: ${JSON.stringify(this.selectors)}]`;
  }

  //// PRIVATE

  _singleTransparentOverlayStrategy() {
    // Only use an overlay
    let selectorName = Object.keys(this.selectors)[0];
    let $element =  this._elementMap[selectorName].element;
    this.overlay.focusOnElement($element);
  }

  _clonedElementStrategy() {
    // Clone elements if multiple selectors
    this._cloneElements(this.selectors);
    if (this.overlay.disableCloneInteraction) {
      this.overlay.showTransparentOverlay();
    }
  }

  _renderTooltip() {
    this.tooltip.render();
  }

  _waitForElements() {
    let promises = [];
    for (let selectorName in this.selectors) {
      let promise = new Promise((resolve, reject) => {
        this._waitForElement(selectorName, 0, resolve, reject);
      });
      promises.push(promise);
    }

    return Promise.all(promises);
  }

  _waitForElement(selectorName, numAttempts, resolve, reject) {
    let selector = this.selectors[selectorName];
    let element = $(selector);
    if (element.length == 0) {
      ++numAttempts;
      if (numAttempts == MAX_ATTEMPTS) {
        reject(`Selector not found: ${selector}`);
      } else {
        window.setTimeout(() => {
          this._waitForElement(selectorName, numAttempts, resolve, reject);
        }, DOM_QUERY_DELAY);
      }
    } else {
      this._elementMap[selectorName].element = element;
      resolve();

      // TODO: fire event when element is ready. Tutorial will listen and call
      // prepare() on all steps
    }
  }

  _computeStyles($element) {
    Style.getComputedStylesFor($element[0]);
    $element.children().toArray().forEach(child => {
      this._computeStyles($(child));
    });
  }

  _cloneElements(selectors) {
    if (this.overlay.isVisible()) return;

    setTimeout(() => {
      this.tutorial.prepare();
    }, 0);
    for (let selectorName in selectors) {
      let clone = this._cloneElement(selectorName);
      this._elementMap[selectorName].clone = clone;
    }
  }

  _cloneElement(selectorName) {
    let $element = this._elementMap[selectorName].element;
    if ($element.length == 0) { return null; }

    let $clone = $element.clone();
    $('body').append($clone);
    this._applyComputedStyles($clone, $element);
    this._positionClone($clone, $element);

    return $clone;
  }

  _applyComputedStyles($clone, $element) {
    if (!$element.is(":visible")) {
      return;
    }
    $clone.addClass('chariot-clone');
    Style.cloneStyles($element, $clone);
    if (this.overlay.disableCloneInteraction) {
      $clone.css('pointer-events', 'none');
    }
    let clonedChildren = $clone.children().toArray();
    $element.children().toArray().forEach((child, index) => {
      this._applyComputedStyles($(clonedChildren[index]), $(child));
    });
  }

  _positionClone($clone, $element) {
    $clone.css({
      'z-index': Constants.CLONE_Z_INDEX,
      position: 'absolute'
    });
    $clone.offset($element.offset());
  }
}

export default Step;
