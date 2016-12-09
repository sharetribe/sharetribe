import * as actionTypes from '../constants/ManageAvailabilityConstants';
import * as harmony from '../services/harmony';
import { Map, List } from 'immutable';

export const allowDay = (day) => ({
  type: actionTypes.ALLOW_DAY,
  payload: day,
});

export const blockDay = (day) => ({
  type: actionTypes.BLOCK_DAY,
  payload: day,
});

const changeVisibleMonth = (day) => ({
  type: actionTypes.CHANGE_MONTH,
  payload: day,
});

export const dataLoaded = (slots) => ({
  type: actionTypes.DATA_LOADED,
  payload: slots,
});

export const changeMonth = (day) =>
  (dispatch, getState) => {
    dispatch(changeVisibleMonth(day));

    const state = getState().manageAvailability;

    harmony.get('/bookables/show', {
      refId: state.get('listingUuid'),
      marketplaceId: state.get('marketplaceUuid'),
      include: ['blocks', 'bookings'].join(','),
    }).then((response) => {
      const groups = response.get(':included').groupBy((v) => v.get(':type'));

      const slots = new Map({
        blocks: groups.get(':block', new List()),
        bookings: groups.get(':booking', new List()),
      });

      dispatch(dataLoaded(slots));
    });

    // TODO ADD ERROR HANDLING
  };

export const saveChanges = () => ({
  type: actionTypes.SAVE_CHANGES,
});

export const openEditView = () => ({
  type: actionTypes.OPEN_EDIT_VIEW,
});

export const closeEditView = () => ({
  type: actionTypes.CLOSE_EDIT_VIEW,
});
