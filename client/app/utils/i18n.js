/* eslint-env commonjs */

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

import { span } from 'r-dom';
import { bind, includes } from 'lodash';

const isServer = function isServer() {
  return typeof window === 'undefined';
};

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

const missingTranslationMessage = function missingTranslationMessage(scope) {
  return `[missing "${scope}" translation]`;
};

const initialize = function initialize(i18nLocale, i18nDefaultLocale, env, localeInfo) {
  I18n.locale = i18nLocale;
  I18n.defaultLocale = i18nDefaultLocale;
  I18n.interpolationMode = 'split';
  I18n.localeInfo = localeInfo != null ? localeInfo : { ident: i18nLocale };

  if (env === 'development') {
    I18n.missingTranslation = function displayMissingTranslation(scope) {
      return span({ className: 'missing-translation', style: { backgroundColor: 'red !important' } }, missingTranslationMessage(scope));
    };
  } else {
    I18n.missingTranslation = function guessMissingTranslation(scope) {
      // This is a sligthly modified guess function. Original:
      // https://github.com/fnando/i18n-js/blob/2ca6d31365bb41db21e373d126cac00d38d15144/app/assets/javascripts/i18n.js#L536

      // Get only the last portion of the scope
      const s = scope.split('.').slice(-1)[0];

      // Replace underscore with space && camelcase with space and lowercase letter
      const guess = s
              .replace(/_/g, ' ')
              .replace(/([a-z])([A-Z])/g, (match, p1, p2) => `${p1} ${p2.toLowerCase()}`);

      const uppercasedGuess = guess[0].toUpperCase() + guess.substr(1);

      return (this.missingTranslationPrefix.length > 0 ? this.missingTranslationPrefix : '') + uppercasedGuess;
    };
  }
};

const localizedString = function localizedString(localizationMap, scope) {
  if (localizationMap == null || localizationMap.size === 0) {
    return missingTranslationMessage(scope);
  }

  if (localizationMap.get(I18n.locale)) {
    return localizationMap.get(I18n.locale);
  } else if (localizationMap.get(I18n.defaultLocale)) {
    return localizationMap.get(I18n.defaultLocale);
  } else {
    return localizationMap.first();
  }
};

const localizedPricingUnit = function localizedPricingUnit(pricingUnit) {
  const pricingUnitType = pricingUnit.get(':unit');
  if (pricingUnitType === 'custom') {
    return localizedString(pricingUnit.get(':customTranslations'), 'pricing unit');
  } else if (includes(['piece', 'hour', 'day', 'night', 'week', 'month'], pricingUnitType)) {
    return I18n.t(`web.listings.pricing_units.${pricingUnitType}`);
  }
  return missingTranslationMessage(pricingUnitType);
};

const currentLocale = function currentLocale() {
  return I18n.localeInfo;
};

const fullLocaleCode = function fullLocaleCode() {
  const localeInfo = currentLocale();
  if (!(localeInfo && localeInfo.language && localeInfo.region)) {
    throw new Error('No locale found');
  }

  return `${localeInfo.language.toLowerCase()}-${localeInfo.region.toUpperCase()}`;
};

// Bind functions to I18n
const translate = bind(I18n.translate, I18n);
const localize = bind(I18n.localize, I18n);
const pluralize = bind(I18n.pluralize, I18n);
const t = bind(I18n.t, I18n);
const l = bind(I18n.l, I18n);
const p = bind(I18n.p, I18n);

export {
  currentLocale,
  fullLocaleCode,
  initialize,
  localize,
  localizedString,
  localizedPricingUnit,
  pluralize,
  translate,
  l,
  p,
  t,
};
