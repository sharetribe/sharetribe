import r from 'r-dom';
import { initialize as initializeI18n } from '../utils/i18n';
import Topbar from '../components/sections/Topbar/Topbar';
import { subset } from '../utils/routes';

export default (props, railsContext) => {
  initializeI18n(railsContext.i18nLocale, railsContext.i18nDefaultLocale, process.env.NODE_ENV);

  const routes = subset([
    'new_listing',
    'person_inbox',
    'person',
    'person_settings',
    'logout',
  ], { locale: railsContext.i18nLocale });

  const combinedProps = Object.assign({}, props, { railsContext, routes });
  return r(Topbar, combinedProps);
};
