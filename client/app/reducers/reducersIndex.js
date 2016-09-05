import onboardingGuideReducer from './OnboardingGuideReducer';
import searchPageReducer from './SearchPageReducer';
import routesReducer from './RoutesReducer';

// This is how you do a directory of reducers.
// The `import * as reducers` does not work for a directory, but only with a single file
export default {
  marketplaceContext: (state = {}) => state,
  onboarding_guide_page: onboardingGuideReducer,
  searchPage: searchPageReducer,
  routes: routesReducer,
};
