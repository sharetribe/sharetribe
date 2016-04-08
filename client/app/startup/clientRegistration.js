import ReactOnRails from 'react-on-rails';
import Promise from 'es6-promise';
import OnboardingTopBar from '../components/OnboardingTopBar/OnboardingTopBar';
import OnboardingGuideApp from './OnboardingGuideApp';

Promise.polyfill();

ReactOnRails.register({
  OnboardingGuideApp,
  OnboardingTopBar,
});

ReactOnRails.registerStore({
});
