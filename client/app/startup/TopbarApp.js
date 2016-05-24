import r from 'r-dom';
import { initialize as initializeI18n } from '../utils/i18n';
import Topbar from '../components/Topbar/Topbar';

export default (props, railsContext) => {
  initializeI18n(railsContext);

  return r(Topbar, props);
};
