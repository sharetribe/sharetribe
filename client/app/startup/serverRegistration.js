// Shows the mapping from the exported object to the name used by the server rendering.
import ReactOnRails from 'react-on-rails';

import OnboardingGuideApp from './OnboardingGuideApp';
import OnboardingTopBar from '../components/OnboardingTopBar/OnboardingTopBar';

ReactOnRails.register({
  OnboardingGuideApp,
  OnboardingTopBar,
});

ReactOnRails.registerStore({
});
