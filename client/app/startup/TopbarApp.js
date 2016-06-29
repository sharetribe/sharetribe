import r from 'r-dom';
import { initialize as initializeI18n } from '../utils/i18n';
import Topbar from '../components/sections/Topbar/Topbar';
import { subset } from '../utils/routes';

export default (props, railsContext) => {
  const locale = props.i18n ? props.i18n.locale : railsContext.i18nLocale;
  const defaultLocale = props.i18n ? props.i18n.defaultLocale : railsContext.i18nDefaultLocale;

  initializeI18n(locale, defaultLocale, process.env.NODE_ENV);

  const routes = subset([
    'new_listing',
    'person_inbox',
    'person',
    'person_settings',
    'logout',
  ], { locale });

  const combinedProps = Object.assign({}, props, { railsContext, routes });
  return r(Topbar, combinedProps);
};
