import r from 'r-dom';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import { Provider } from 'react-redux';
import { initializeEnvironment } from '../utils/initialize-env';
import { subset } from '../utils/routes';
import middleware from 'redux-thunk';

// Uses the index
import reducers from '../reducers/reducersIndex';

import OnboardingGuideContainer from '../components/OnboardingGuide/OnboardingGuideContainer';

export default (props, railsContext) => {
  initializeEnvironment(railsContext, process.env.NODE_ENV);

  const routes = subset([
    "admin_getting_started_guide_slogan_and_description"
  ]);

  const combinedReducer = combineReducers(reducers);
  const combinedProps = Object.assign({}, props, { railsContext, routes });

  const store = applyMiddleware(middleware)(createStore)(combinedReducer, combinedProps);

  return r(Provider, { store }, [
    r(OnboardingGuideContainer),
  ]);
};
