import ReactOnRails from 'react-on-rails';
import Promise from 'es6-promise';
Promise.polyfill();

import OnboardingTopBar from './OnboardingTopBarApp';
import OnboardingGuideApp from './OnboardingGuideApp';
import TopbarApp from './TopbarApp';

ReactOnRails.register({
  OnboardingGuideApp,
  OnboardingTopBar,
  TopbarApp,
});

ReactOnRails.registerStore({
});
