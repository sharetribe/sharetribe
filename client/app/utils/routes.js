/* eslint-env commonjs */

let Routes = {};

try {
  Routes = require('../routes/routes.js');
} catch (e) {
  console.warn('Can not load route bundle routes.js'); // eslint-disable-line no-console
}

function initialize(railsContext) {
  Routes.options.default_url_options.locale = railsContext.i18nLocale;
}

export { Routes, initialize };
