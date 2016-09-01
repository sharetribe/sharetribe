import r from 'r-dom';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import { Provider } from 'react-redux';
import Immutable from 'immutable';
import middleware from 'redux-thunk';
import { initialize as initializeI18n } from '../utils/i18n';
import { subset } from '../utils/routes';
import TransitImmutable from '../utils/transitImmutable';

import reducers from '../reducers/reducersIndex';
import SearchPageContainer from '../components/sections/SearchPage/SearchPageContainer';

export default (props) => {
  const locale = props.i18n.locale;
  const defaultLocale = props.i18n.defaultLocale;

  initializeI18n(locale, defaultLocale, process.env.NODE_ENV);

  const routes = subset([
    'listing',
    'person',
  ], { locale });

  const bootstrappedData = TransitImmutable.fromJSON(props.data);

  // These will change when DiscoveryAPI is ready
  const Listing = Immutable.Record({
    id: 'uuid',
    title: 'Listing',
  });

  const searchPage = new Immutable.Map({
    prevPage: new Immutable.List(),
    currentPage: bootstrappedData.map((l) => l.get(':id')),
    nextPage: new Immutable.List(),
    listings: bootstrappedData
      .get(':data')
      .map((l) => new Listing({
        id: l.get(':id'),
        title: l.get(':source').get(':title'),
      }))
      .toSet(),
  });

  const combinedProps = Object.assign({}, { searchPage }, { routes });
  const combinedReducer = combineReducers(reducers);

  const store = applyMiddleware(middleware)(createStore)(combinedReducer, combinedProps);

  return r(Provider, { store }, [
    r(SearchPageContainer),
  ]);
};
