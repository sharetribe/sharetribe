import onboardingGuideReducer from './OnboardingGuideReducer';
import flashNotificationReducer from './FlashNotificationReducer';
import searchPageReducer from './SearchPageReducer';
import routesReducer from './RoutesReducer';

// This is how you do a directory of reducers.
// The `import * as reducers` does not work for a directory, but only with a single file
export default {
  flashNotifications: flashNotificationReducer,
  marketplaceContext: (state = {}) => state,
  marketplace: (state = {}) => state,
  onboarding_guide_page: onboardingGuideReducer,
  searchPage: searchPageReducer,
  routes: routesReducer,
  listings: (state = {}) => state,
  profiles: (state = {}) => state,
  topbar: (state = {}) => state,
};
