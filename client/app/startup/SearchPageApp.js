import r from 'r-dom';
import _ from 'lodash';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import { Provider } from 'react-redux';
import middleware from 'redux-thunk';
import Immutable from 'immutable';

import { initialize as initializeI18n } from '../utils/i18n';
import { subset } from '../utils/routes';

import FlashNotificationModel from '../models/FlashNotificationModel';
import reducers from '../reducers/reducersIndex';
import SearchPageContainer from '../components/sections/SearchPage/SearchPageContainer';
import { SearchPageModel } from '../components/sections/SearchPage/SearchPage';
import { parse as parseListingModel } from '../models/ListingModel';
import { parse as parseProfile } from '../models/ProfileModel';
import TransitImmutableConverter from '../utils/transitImmutableConverter';

const profilesToMap = (includes) =>
  includes.reduce((acc, val) => {
    const type = val.get(':type');
    if (type === ':profile') {
      const profile = parseProfile(val);
      const id = val.get(':id');
      return acc.set(id, profile);
    } else {
      return acc;
    }
  }, new Immutable.Map());

const listingsToMap = (listings) =>
  listings.reduce((acc, val) => {
    const listing = parseListingModel(val);
    return acc.set(listing.id, listing);
  }, new Immutable.Map());

const systemNotificationsToList = (serverNotifications) => {
  const alerts = _.map(serverNotifications, (value, prop) => (
    new FlashNotificationModel({
      id: prop,
      type: prop,
      content: value,
      isRead: false,
    })
  ));
  return new Immutable.List(alerts);
};


export default (props) => {
  const locale = props.i18n.locale;
  const defaultLocale = props.i18n.defaultLocale;
  const localeInfo = props.i18n.localeInfo;

  initializeI18n(locale, defaultLocale, process.env.NODE_ENV, localeInfo);

  const routes = subset([
    'listing',
    'person',
  ], { locale });

  const bootstrappedData = TransitImmutableConverter.fromJSON(props.data);

  const rawListings = bootstrappedData
    .get(':data');

  const listings = listingsToMap(rawListings);
  const profiles = profilesToMap(bootstrappedData.get(':included'));
  const searchPage = new SearchPageModel({
    currentPage: rawListings.map((l) => l.get(':id')),
  });
  const { notifications, ...marketplaceInfo } = props.marketplace;
  const flashNotifications = systemNotificationsToList(notifications);

  const combinedProps = {
    flashNotifications,
    listings,
    marketplace: marketplaceInfo,
    profiles,
    routes,
    searchPage,
  };
  const combinedReducer = combineReducers(reducers);

  const store = applyMiddleware(middleware)(createStore)(combinedReducer, combinedProps);

  return r(Provider, { store }, [
    r(SearchPageContainer),
  ]);
};
