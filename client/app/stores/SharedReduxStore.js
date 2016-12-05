import { combineReducers, applyMiddleware, createStore } from 'redux';
import middleware from 'redux-thunk';

import reducers from '../reducers/reducersIndex';

/*
 *  Export a function that takes the props and returns a Redux store
 *  This is used so that 2 components can have the same store.
 *
 *  The base for this file is copied from:
 *  https://github.com/shakacode/react_on_rails/blob/c2b85c9ef12ece4b8eaaeb448f4d45c1e7ac3223/spec/dummy/client/app/stores/SharedReduxStore.jsx
 */
export default (props) => {
  const combinedReducer = combineReducers(reducers);

  // If you want to include railsContext to props, do it here.

  return applyMiddleware(middleware)(createStore)(combinedReducer, props);
};
