import r from 'r-dom';
import { initializeEnvironment } from '../utils/initialize-env';
import OnboardingTopBar from '../components/OnboardingTopBar/OnboardingTopBar';
import { subset } from '../utils/routes';

export default (props, railsContext) => {
  initializeEnvironment(railsContext, process.env.NODE_ENV);

  const routes = subset([
    'admin_getting_started_guide',
  ], { locale: railsContext.i18nLocale });

  const combinedProps = Object.assign({}, props, { routes });

  return r(OnboardingTopBar, combinedProps);
};
