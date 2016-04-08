
import ReactOnRails from 'react-on-rails';

import ReduxApp from './ExampleReduxApp';
import OnboardingTopBar from '../components/OnboardingTopBar/OnboardingTopBar';

import OnboardingGuideApp from './OnboardingGuideApp';

ReactOnRails.register({
  ReduxApp,
  OnboardingGuideApp,
  OnboardingTopBar,
});

ReactOnRails.registerStore({
});
