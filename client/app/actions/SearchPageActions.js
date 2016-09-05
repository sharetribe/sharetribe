import { List } from 'immutable';
import * as actionTypes from '../constants/SearchPageConstants';

export function updateCurrentPage({ listings = new List() } = {}) {
  return {
    type: actionTypes.CURRENT_PAGE_UPDATE,
    payload: {
      currentPage: listings.map((l) => l.get(':id')),
      listings,
    },
  };
}
