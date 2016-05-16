import r from 'r-dom';
import { initialize as initializeI18n } from '../utils/i18n';
import OnboardingTopBar from '../components/OnboardingTopBar/OnboardingTopBar';

export default (props, railsContext) => {
  initializeI18n(railsContext);

  return r(OnboardingTopBar, props);
};
