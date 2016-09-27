import r from 'r-dom';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import { Provider } from 'react-redux';
import middleware from 'redux-thunk';
import Immutable from 'immutable';

import { initialize as initializeI18n } from '../utils/i18n';
import { subset } from '../utils/routes';

import reducers from '../reducers/reducersIndex';
import SearchPageContainer from '../components/sections/SearchPage/SearchPageContainer';
import { SearchPageModel } from '../components/sections/SearchPage/SearchPage';
import { parse as parseListingModel } from '../models/ListingModel';
import TransitImmutableConverter from '../utils/transitImmutableConverter';


export default (props) => {
  const locale = props.i18n.locale;
  const defaultLocale = props.i18n.defaultLocale;

  initializeI18n(locale, defaultLocale, process.env.NODE_ENV);

  const routes = subset([
    'listing',
    'person',
  ], { locale });

  const bootstrappedData = TransitImmutableConverter.fromJSON(props.data);

  const listingsToMap = (listings) =>
    listings.reduce((acc, val) => {
      const listing = parseListingModel(val);
      return acc.set(listing.id, listing);
    }, new Immutable.Map());

  const rawListings = bootstrappedData
    .get(':data')
    .get(0);

  const searchPage = new SearchPageModel({
    currentPage: bootstrappedData.get(':data')
      .get(0)
      .map((l) => l.get(':id')),
    listings: listingsToMap(rawListings),
  });

  const combinedProps = Object.assign({}, { searchPage }, { routes });
  const combinedReducer = combineReducers(reducers);

  const store = applyMiddleware(middleware)(createStore)(combinedReducer, combinedProps);

  return r(Provider, { store }, [
    r(SearchPageContainer),
  ]);
};
