import Routes from '../routes/routes';

function initialize(railsContext) {
  Routes.options.default_url_options.locale = railsContext.i18nLocale;
}

export { Routes, initialize };
