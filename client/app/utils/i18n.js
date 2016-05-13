// This file has three tasks:
//
// 1. Initialize global.I18n if we are in server environment
// 1. Load the language bundle if we are in server environment
// 2. Require the i18n-js library and export it
//
// The language bundle is loaded in a global I18n variable like this:
//
// `global.I18n.translations["en"] = <translation json>`
//
// The i18n-js library is able to read the language bundle from that global
//

import { bind } from 'lodash';

function isServer() {
  return typeof window === 'undefined';
}

if (isServer()) {

  // Initialize global.I18n
  // In browser we initialize this in a script-tag manually
  global.I18n = {};

  // Load the translation bundle in the global.I18n variable.
  // In browser the bundle is loaded in a separate script-tag.

  try {
    // The translation bundle will be loaded to the global I18n
    // variable. Initialize the variable here.
    require('../i18n/all.js');
  } catch (e) {
    console.warn("Can't load language bundle all.js"); // eslint-disable-line no-console
  }
}

// Load the i18n-js library. The library is able to read the
// translations from the global.I18n variable. This variable needs to
// be initialized before loading the i18n-js library, so that the
// library can use the existing I18n object

const I18n = require('i18n-js');

function initialize(railsContext) {
  I18n.locale = railsContext.i18nLocale;
  I18n.defaultLocale = railsContext.i18nDefaultLocale;
  I18n.interpolationMode = 'split';
}

// Bind functions to I18n
const translate = bind(I18n.translate, I18n);
const localize = bind(I18n.localize, I18n);
const pluralize = bind(I18n.pluralize, I18n);
const t = bind(I18n.t, I18n);
const l = bind(I18n.l, I18n);
const p = bind(I18n.p, I18n);

export { initialize, translate, localize, pluralize, t, l, p };
