import r from 'r-dom';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import { Provider } from 'react-redux';
import { initialize as initializeI18n } from '../utils/i18n';
import middleware from 'redux-thunk';

// Uses the index
import reducers from '../reducers/reducersIndex';
import composeInitialState from '../store/composeInitialState';

import OnboardingGuideContainer from '../components/onboardingGuide/OnboardingGuideContainer';

export default (props, railsContext) => {
  initializeI18n(railsContext, process.env.NODE_ENV);

  const combinedReducer = combineReducers(reducers);
  const combinedProps = composeInitialState(props, railsContext);

  const store = applyMiddleware(middleware)(createStore)(combinedReducer, combinedProps);

  return r(Provider, { store }, [
    r(OnboardingGuideContainer),
  ]);
};
