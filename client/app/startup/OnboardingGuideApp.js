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
    'admin_getting_started_guide',
    'admin_getting_started_guide_slogan_and_description',
    'admin_getting_started_guide_cover_photo',
    'admin_getting_started_guide_filter',
    'admin_getting_started_guide_paypal',
    'admin_getting_started_guide_listing',
    'admin_getting_started_guide_invitation',
    'admin_look_and_feel_edit',
    'admin_details_edit',
    'admin_custom_fields',
    'admin_paypal_preferences',
    'edit_admin_listing_shape',
    'new_invitation',
    'new_listing',
  ], { locale: railsContext.i18nLocale });

  const combinedReducer = combineReducers(reducers);
  const combinedProps = Object.assign({}, props, { railsContext, routes });

  const store = applyMiddleware(middleware)(createStore)(combinedReducer, combinedProps);

  return r(Provider, { store }, [
    r(OnboardingGuideContainer),
  ]);
};
