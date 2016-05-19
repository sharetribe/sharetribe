import r from 'r-dom';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import { Provider } from 'react-redux';
import { initializeEnvironment } from '../utils/initialize-env';
import middleware from 'redux-thunk';

// Uses the index
import reducers from '../reducers/reducersIndex';
import composeInitialState from '../store/composeInitialState';

import OnboardingGuideContainer from '../components/OnboardingGuide/OnboardingGuideContainer';

export default (props, railsContext) => {
  initializeEnvironment(railsContext, process.env.NODE_ENV);

  const combinedReducer = combineReducers(reducers);
  const combinedProps = composeInitialState(props, railsContext);

  const store = applyMiddleware(middleware)(createStore)(combinedReducer, combinedProps);

  return r(Provider, { store }, [
    r(OnboardingGuideContainer),
  ]);
};
