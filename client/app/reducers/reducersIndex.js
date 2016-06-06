import railsContextReducer from './RailsContextReducer';
import onboardingGuideReducer from './OnboardingGuideReducer';
import routesReducer from './RoutesReducer';

// This is how you do a directory of reducers.
// The `import * as reducers` does not work for a directory, but only with a single file
export default {
  railsContext: railsContextReducer,
  onboarding_guide_page: onboardingGuideReducer,
  routes: routesReducer,
};
