/* global
history, location
*/

/* Please refer to example page to see how a typical configuration is structured */

import Tutorial from './tutorial';

require('./ie-shim');

let initialState = true;

class Chariot {
  /**
   * The master Chariot configuration dictionary can consist of multiple
   *  tutorial configurations.
   * @typedef ChariotConfiguration
   * @property {Object.<string, TutorialConfig>} config - The main configuration
   *  containing all tutorials.
   *
   */

  /**
   * The delegate optionally responds to lifecycle callbacks from Chariot.
   * @typedef ChariotDelegate
   * @property {Object} delegate - The object that responds to the
   *  following lifecycle callbacks.
   *
   * <ol>
   *   <li>willBeginTutorial</li>
   *   <li>The following are repeated for each step.</li>
   *   <ol>
   *     <li>willBeginStep</li>
   *     <li>willRenderOverlay</li>
   *     <li>didShowOverlay</li>
   *     <li>willRenderTooltip</li>
   *     <li>didRenderTooltip</li>
   *     <li>didFinishStep</li>
   *   </ol>
   *   <li>didFinishTutorial</li>
   * </ol>
   */

  /**
   * Called once before a tutorial begins.
   * @callback willBeginTutorial
   * @param {Tutorial} tutorial - The Tutorial object
   */

  /**
   * Called once after a tutorial is finished.
   * @callback didFinishTutorial tutorial
   * @param {Tutorial} tutorial - The Tutorial object
   * @param {boolean} forced - Indicates whether tutorial was forced to end
   */

  /**
   * Called once before each step begins.
   * Return a promise here if you have async callbacks you want resolved before
   * continuing.
   * @callback willBeginStep
   * @param {Step} step - The current Step object
   * @param {int} stepIndex - Index of current Step
   * @param {Tutorial} tutorial - The Tutorial object corresponding to this Step
   * @returns {Promise} [promise] Return a promise if you have async callbacks
   *   that must be resolved before continuing.
   */

  /**
   * Called once after each step is finished.
   * @callback didFinishStep
   * @param {Step} step - The current Step object
   * @param {int} stepIndex - Index of current Step
   * @param {Tutorial} tutorial - The Tutorial object corresponding to this Step
   * @returns {Promise} [promise] Return a promise if you have async callbacks
   *   that must be resolved before continuing.
   */

  /**
   * Called once before each overlay is shown.
   * @callback willShowOverlay
   * @param {Overlay} overlay - The current Overlay object
   * @param {int} stepIndex - Index of current Step
   * @param {Tutorial} tutorial - The Tutorial object corresponding to this Step
   * @returns {Promise} [promise] Return a promise if you have async callbacks
   *   that must be resolved before continuing.
   */

  /**
   * Called once after each overlay is shown.
   * @callback didShowOverlay
   * @param {Overlay} overlay - The current Overlay object
   * @param {int} stepIndex - Index of current Step
   * @param {Tutorial} tutorial - The Tutorial object corresponding to this Step
   * @returns {Promise} [promise] Return a promise if you have async callbacks
   *   that must be resolved before continuing.
   */

  /**
   * Called once before each tooltip is rendered.
   * @callback willRenderTooltip
   * @param {Tooltip} tooltip - The current Tooltip object
   * @param {int} stepIndex - Index of current Step
   * @param {Tutorial} tutorial - The Tutorial object corresponding to this Step
   * @returns {Promise} [promise] Return a promise if you have async callbacks
   *   that must be resolved before continuing.
   */

  /**
   * Called once after each tooltip is rendered.
   * @callback didRenderTooltip
   * @param {Tooltip} tooltip - The current Tooltip object
   * @param {int} stepIndex - Index of current Step
   * @param {Tutorial} tutorial - The Tutorial object corresponding to this Step
   * @returns {Promise} [promise] Return a promise if you have async callbacks
   *   that must be resolved before continuing.
   */

  /**
   * @constructor
   * @param {ChariotConfiguration} config - The main configuration for all
   *  tutorials
   * @param {ChariotDelegate} [delegate] - An optional delegate that responds to
   *  lifecycle callbacks
   */
  constructor(config, delegate) {
    this.config = config;
    this.delegate = delegate;
    this.tutorials = {};
    this._readConfig(config);
  }

  /**
   * Sets the chariot delegate.
   * @param {ChariotDelegate} [delegate] - An object that responds to
   *  lifecycle callbacks
   */
  setDelegate(delegate) {
    this.delegate = delegate;
  }

  /**
   * Starts a tutorial with the given name.
   * Won't start a tutorial if one is currently running.
   * @param {string} name - Name of the tutorial to start
   * @returns {Tutorial} tutorial - The Tutorial object, or undefined if
   *  another tutorial is currently active.
   */
  startTutorial(name) {
    if (this.currentTutorial()) {
      return;
    }
    const tutorial = this.tutorials[name];
    tutorial.start();
    return tutorial;
  }

  /**
   * Ends the current tutorial.
   * @returns {undefined}
   */
  endTutorial() {
    const tutorial = this.currentTutorial();
    tutorial.end(true);
  }

  /**
   * Returns the current tutorial, if any.
   * @returns {Tutorial} tutorial - The current tutorial, or null if none active
   */
  currentTutorial() {
    for (let tutorialName in this.tutorials) {
      let tutorial = this.tutorials[tutorialName];
      if (tutorial.isActive()) return tutorial;
    }
  }

  /**
   * Static method for creating a Tutorial object without needing to instantiate
   * chariot with a large configuration and named tutorials.
   * @param {TutorialConfiguration} config - The tutorial configuration
   * @param {ChariotDelegate} [delegate] - An optional delegate that responds to
   *  lifecycle callbacks
   */
  static createTutorial(config, delegate) {
    return new Tutorial(config, '', delegate);
  }

  /**
   * Static method for creating and starting a Tutorial object without needing
   * to instantiate chariot with a large configuration and named tutorials.
   * @param {TutorialConfiguration} config - The tutorial configuration
   * @param {ChariotDelegate} [delegate] - An optional delegate that responds to
   *  lifecycle callbacks
   */
  static startTutorial(config, delegate) {
    const tutorial = this.createTutorial(config, delegate);
    tutorial.start();
    return tutorial;
  }

  toString() {
    return `[Chariot - config: ${this.config}, tutorials: {this.tutorials}]`;
  }

  //// PRIVATE

  _readConfig(config) {
    if (!config || typeof config !== 'object') {
      throw new Error(`Config must contains a tutorials hash.\n${this}`);
    }
    for (let tutorialName in config) {
      this.tutorials[tutorialName] = new Tutorial(
        config[tutorialName], tutorialName, this.delegate);
    }
  }
}

export
default Chariot;
