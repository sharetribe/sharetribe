import r from 'r-dom';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import { Provider } from 'react-redux';
import middleware from 'redux-thunk';
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
  const searchPage = new SearchPageModel({
    currentPage: bootstrappedData.get(':data')
      .get(0)
      .map((l) => l.get(':id')),
    listings: bootstrappedData
      .get(':data')
      .get(0)
      .map(parseListingModel),
  });

  const combinedProps = Object.assign({}, { searchPage }, { routes });
  const combinedReducer = combineReducers(reducers);

  const store = applyMiddleware(middleware)(createStore)(combinedReducer, combinedProps);

  return r(Provider, { store }, [
    r(SearchPageContainer),
  ]);
};
