import r from 'r-dom';
import { Provider } from 'react-redux';
import middleware from 'redux-thunk';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import reducers from '../reducers/reducersIndex';
import { initialize as initializeI18n } from '../utils/i18n';
import moment from 'moment';
import ManageAvailabilityContainer from '../components/sections/ManageAvailability/ManageAvailabilityContainer';

export default (props) => {
  const locale = props.i18n.locale;
  const defaultLocale = props.i18n.defaultLocale;

  initializeI18n(locale, defaultLocale, process.env.NODE_ENV);
  moment.locale(locale);

  const combinedReducer = combineReducers(reducers);
  const store = applyMiddleware(middleware)(createStore)(combinedReducer, {});

  return r(Provider, { store }, [
    r(ManageAvailabilityContainer, {}),
  ]);
};
