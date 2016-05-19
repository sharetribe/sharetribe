import r from 'r-dom';
import { initializeEnvironment } from '../utils/initialize-env';
import OnboardingTopBar from '../components/OnboardingTopBar/OnboardingTopBar';

export default (props, railsContext) => {
  initializeEnvironment(railsContext, process.env.NODE_ENV);

  return r(OnboardingTopBar, props);
};
