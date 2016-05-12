import { configure } from '@kadira/storybook';
//import '../app/components/OnboardingTopbar/OnboardingTopbar.scss';

function loadStories() {
  require('../app/components/OnboardingTopbar/OnboardingTopbar.story.js');
  // require as many stories as you need.
}

configure(loadStories, module);
