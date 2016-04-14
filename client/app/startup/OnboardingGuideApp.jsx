import React from 'react';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import { Provider } from 'react-redux';
import middleware from 'redux-thunk';

// Uses the index
import reducers from '../reducers/reducersIndex';
import composeInitialState from '../store/composeInitialState';

import OnboardingGuideContainer from '../components/onboardingGuide/OnboardingGuideContainer';

export default (props, railsContext) => {
  const combinedReducer = combineReducers(reducers);
  const combinedProps = composeInitialState(props, railsContext);

  const store = applyMiddleware(middleware)(createStore)(combinedReducer, combinedProps);

  return (
    <Provider store={store}>
      <OnboardingGuideContainer />
    </Provider>
  );
};
