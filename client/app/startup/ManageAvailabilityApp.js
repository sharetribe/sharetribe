import Immutable from 'immutable';
import r from 'r-dom';
import { Provider } from 'react-redux';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import middleware from 'redux-thunk';
import moment from 'moment';
import throttle from 'lodash/throttle';

// local imports
import ManageAvailabilityContainer from '../components/sections/ManageAvailability/ManageAvailabilityContainer';
import reducers from '../reducers/reducersIndex';
import * as cssVariables from '../assets/styles/variables';
import { EDIT_VIEW_OPEN_HASH, hasChanges } from '../reducers/ManageAvailabilityReducer';
import { initialize as initializeI18n } from '../utils/i18n';
import { loadAvailabilityChanges, saveAvailabilityChanges } from '../services/localStorage';
import { UUID } from '../types/types';

const AVAILABILITY_CHANGES = 'Availability changes';
const LOCALSTORAGE_THROTTLE = 1000;

// Clean the store, if there is no actual transient changes
const trimAvailabilityChanges = (store) => {
  const manageAvailabilityState = store.getState().manageAvailability;
  if (hasChanges(manageAvailabilityState)) {
    return manageAvailabilityState.get('changes');
  }
  return [];
};

const persistAvailabilityChanges = (store) =>
  store.subscribe(throttle(() => {
    saveAvailabilityChanges(
      AVAILABILITY_CHANGES,
      trimAvailabilityChanges(store));
  }, LOCALSTORAGE_THROTTLE));

export default (props) => {
  const locale = props.i18n.locale;
  const defaultLocale = props.i18n.default_locale;

  initializeI18n(locale, defaultLocale, process.env.NODE_ENV);
  moment.locale(locale);

  const combinedReducer = combineReducers(reducers);

  const persistedChanges = loadAvailabilityChanges(AVAILABILITY_CHANGES);
  const initialStoreState = {
    flashNotifications: new Immutable.List(),
    manageAvailability: new Immutable.Map({
      isOpen: window.location.hash.replace(/^#/, '') === EDIT_VIEW_OPEN_HASH,
      visibleMonth: moment()
        .utc()
        .startOf('month'),
      reservedDays: new Immutable.List(),
      blockedDays: new Immutable.List(),
      changes: persistedChanges,
      marketplaceUuid: new UUID({ value: props.marketplace.uuid }),
      listingUuid: new UUID({ value: props.listing.uuid }),
      loadedMonths: new Set(),
    }),
  };

  const store = applyMiddleware(middleware)(createStore)(combinedReducer, initialStoreState);

  // Save availability changes to localstore
  persistAvailabilityChanges(store);

  const containerProps = {
    availability_link: props.availability_link_id ?
      document.getElementById(props.availability_link_id) :
      null,
    header: {
      backgroundColor: props.marketplace.marketplace_color1 || cssVariables['--customColorFallback'],
      imageUrl: props.listing.image_url,
      title: props.listing.title,
      height: cssVariables['--ManageAvailabilityHeader_height'],
    },
  };

  return r(Provider, { store }, [
    r(ManageAvailabilityContainer, containerProps),
  ]);
};
