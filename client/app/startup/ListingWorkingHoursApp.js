import r from 'r-dom';
import { Provider } from 'react-redux';
import middleware from 'redux-thunk';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import reducers from '../reducers/reducersIndex';
import { initialize as initializeI18n } from '../utils/i18n';
import moment from 'moment';
import Immutable from 'immutable';
import ListingWorkingHours from '../components/sections/ListingWorkingHours/ListingWorkingHours';
import * as convert from '../components/sections/ListingWorkingHours/convert';
import { EDIT_VIEW_OPEN_HASH } from '../components/sections/ListingWorkingHours/actions';
import * as cssVariables from '../assets/styles/variables';


export default (props) => {
  const locale = props.i18n.locale;
  const defaultLocale = props.i18n.default_locale;

  initializeI18n(locale, defaultLocale, process.env.NODE_ENV);
  moment.locale(locale);

  convert.setFirstDayOfWeek(props.first_day_of_week);
  const workingTimeSlots = convert.convertFromApi(props.listing);
  const combinedReducer = combineReducers(reducers);
  const initialStoreState = {
    flashNotifications: Immutable.List(),
    listingWorkingHours: Immutable.Map({
      isOpen: window.location.hash.replace(/^#/, '') === EDIT_VIEW_OPEN_HASH,
      changes: props.listing_just_created,
      saveInProgress: false,
      saveFinished: false,
      listing_id: props.listing.id,
      workingTimeSlots: workingTimeSlots, // eslint-disable-line babel/object-shorthand
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
    time_slot_options: props.time_slot_options,
    day_names: props.day_names,
    first_day_of_week: props.first_day_of_week,
  };

  return r(Provider, { store }, [
    r(ListingWorkingHours, containerProps),
  ]);
};
