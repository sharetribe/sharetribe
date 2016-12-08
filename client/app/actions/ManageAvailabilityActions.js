import * as actionTypes from '../constants/ManageAvailabilityConstants';
import _ from 'lodash';
import * as harmony from '../services/harmony';

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

export const dataLoaded = (bookings, blocks) => ({
  type: actionTypes.DATA_LOADED,
  payload: {
    bookings,
    blocks,
  },
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
      const groups = _.groupBy(response.included, 'type');
      const bookings = groups.booking || [];
      const blocks = groups.blocks || [];

      dispatch(dataLoaded(bookings, blocks));
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
