import { configure } from '@kadira/storybook';
import '../app/assets/styles/base.css';
import '../app/i18n/all';

function loadStories() {
  require('../app/components/OnboardingTopbar/OnboardingTopbar.story.js');
  require('../app/components/Styleguide/ColorsAndTypography.js');
  require('../app/components/Topbar/Logo.story.js');
  require('../app/components/Topbar/Topbar.story.js');
}

configure(loadStories, module);
