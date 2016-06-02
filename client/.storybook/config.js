import { configure } from '@kadira/storybook';
import '../app/assets/styles/base.css';
import '../app/i18n/all';
import { initializeEnvironment } from '../app/utils/initialize-env';

// initializeI18n needs to know railsContext and node_env
initializeEnvironment({ i18nLocale: 'en', i18nDefaultLocale: 'en' }, process.env.NODE_ENV);

const loadStories = function loadStories() {
  require('../app/components/Styleguide/ColorsAndTypography.js');
  require('../app/components/Topbar/Logo.story.js');
  require('../app/components/Topbar/Topbar.story.js');
  require('../app/components/OnboardingTopbar/OnboardingTopbar.story.js');
  require('../app/components/OnboardingGuide/OnboardingGuide.story.js');
};

configure(loadStories, module);
