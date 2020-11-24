import * as actionTypes from '../constants/SearchPageConstants';
import { SearchPageModel } from '../components/sections/SearchPage/SearchPage';

// prevPage, currentPage, and nextPage are Id lists
const initialState = {
  searchPage: new SearchPageModel(),
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
