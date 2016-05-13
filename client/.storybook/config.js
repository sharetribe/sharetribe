import { configure } from '@kadira/storybook';
import '../app/assets/styles/base.scss';

function loadStories() {
  require('../app/components/OnboardingTopbar/OnboardingTopbar.story.js');
  require('../app/components/Styleguide/ColorsAndTypography.js');
}

configure(loadStories, module);
