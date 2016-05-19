// Shows the mapping from the exported object to the name used by the server rendering.
import ReactOnRails from 'react-on-rails';

import OnboardingGuideApp from './OnboardingGuideApp';
import OnboardingTopBar from './OnboardingTopBarApp';
import TopbarApp from './TopbarApp';

ReactOnRails.register({
  OnboardingGuideApp,
  OnboardingTopBar,
  TopbarApp,
});

ReactOnRails.registerStore({
});
