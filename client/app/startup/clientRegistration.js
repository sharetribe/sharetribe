import ReactOnRails from 'react-on-rails';
import React from 'react';
import ReactDOM from 'react-dom';

import OnboardingTopBar from './OnboardingTopBarApp';
import OnboardingGuideApp from './OnboardingGuideApp';
import TopbarApp from './TopbarApp';
import SearchPageApp from './SearchPageApp';
import SharedReduxStore from '../stores/SharedReduxStore';

ReactOnRails.register({
  OnboardingGuideApp,
  OnboardingTopBar,
  TopbarApp,
  SearchPageApp,
});

ReactOnRails.registerStore({
  SharedReduxStore,
});

if (typeof window !== 'undefined') {
  window.React = React;
  window.ReactDOM = ReactDOM;
}
