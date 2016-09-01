import { List, Map, Set } from 'immutable';
import * as actionTypes from '../constants/SearchPageConstants';

// prevPage, currentPage, and nextPage are Id lists
const initialState = {
  searchPage: new Map({
    prevPage: new List(),
    currentPage: new List(),
    nextPage: new List(),
    listings: new Set(),
  }),
};

export default function searchPageReducer(state = initialState, action) {
  const { type, payload } = action;

  switch (type) {
    case actionTypes.CURRENT_PAGE_UPDATE:
      return state
              .set('currentPage', payload.currentPage)
              .set('listings', state.get('listings').union(payload.listings.toSet()));
    default:
      return state;
  }

}
