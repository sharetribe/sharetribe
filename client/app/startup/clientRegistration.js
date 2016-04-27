import ReactOnRails from 'react-on-rails';
import Promise from 'es6-promise';

Promise.polyfill();

import OnboardingGuideApp from './OnboardingGuideApp';

ReactOnRails.register({
  OnboardingGuideApp,
});

ReactOnRails.registerStore({
});
