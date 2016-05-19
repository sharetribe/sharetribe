import { initialize as initializeI18n } from './i18n';
import { initialize as initializeRoutes } from './routes';

// This function is a single point where application initialization
// should happen. Initialization can be for example setting the app
// in correct state based on railsContext or node environment
function initializeEnvironment(railsContext, nodeEnv) {
  initializeI18n(railsContext, nodeEnv);
  initializeRoutes(railsContext);
}

export { initializeEnvironment };
