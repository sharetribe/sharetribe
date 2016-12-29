import r from 'r-dom';
import { Provider } from 'react-redux';
import middleware from 'redux-thunk';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import reducers from '../reducers/reducersIndex';
import { initialize as initializeI18n } from '../utils/i18n';
import moment from 'moment';
import Immutable from 'immutable';
import ManageAvailabilityContainer from '../components/sections/ManageAvailability/ManageAvailabilityContainer';
import { EDIT_VIEW_OPEN_HASH } from '../actions/ManageAvailabilityActions';
import * as cssVariables from '../assets/styles/variables';
import { UUID } from '../types/types';

export default (props) => {
  const locale = props.i18n.locale;
  const defaultLocale = props.i18n.default_locale;

  initializeI18n(locale, defaultLocale, process.env.NODE_ENV);
  moment.locale(locale);

  const combinedReducer = combineReducers(reducers);
  const initialStoreState = {
    flashNotifications: Immutable.List(),
    manageAvailability: Immutable.Map({
      isOpen: window.location.hash.replace(/^#/, '') === EDIT_VIEW_OPEN_HASH,
      visibleMonth: moment()
        .startOf('month'),
      bookings: Immutable.List(),
      blocks: Immutable.List(),
      changes: Immutable.List(),
      saveInProgress: false,
      saveFinished: false,
      marketplaceUuid: new UUID({ value: props.marketplace.uuid }),
      listingUuid: new UUID({ value: props.listing.uuid }),
      loadedMonths: Immutable.Set(),
    }),
  };

  const store = applyMiddleware(middleware)(createStore)(combinedReducer, initialStoreState);

  const containerProps = {
    availability_link: props.availability_link_id ?
      document.getElementById(props.availability_link_id) :
      null,
    header: {
      backgroundColor: props.marketplace.marketplace_color1 || cssVariables['--customColorFallback'],
      imageUrl: props.listing.image_url,
      title: props.listing.title,
    },
    sideWinderWrapper: document.querySelector('#sidewinder-wrapper'),
  };

  return r(Provider, { store }, [
    r(ManageAvailabilityContainer, containerProps),
  ]);
};
