import r from 'r-dom';
import { initialize as initializeI18n } from '../utils/i18n';
import Topbar from '../components/sections/Topbar/Topbar';

export default (props, railsContext) => {
  initializeI18n(railsContext.i18nLocale, railsContext.i18nDefaultLocale, process.env.NODE_ENV);

  return r(Topbar, props);
};
