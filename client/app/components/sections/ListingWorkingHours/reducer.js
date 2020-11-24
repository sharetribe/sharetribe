import Immutable from 'immutable';
import * as actionTypes from './constants';
import * as convert from './convert';

const initialState = Immutable.Map({
  isOpen: true,
  changes: false,

  saveInProgress: false,
  saveFinished: false,

  listing_id: null,
  workingTimeSlots: null,
});

const clearState = (state) =>
      state
      .set('isOpen', false)
      .set('changes', false)
      .set('saveInProgress', false)
      .set('saveFinished', false);

const dataChanged = (state) =>
  state.set('saveFinished', false).set('changes', true);

const dataLoaded = (state, payload) => {
  const workingTimeSlots = convert.convertFromApi(payload);
  return state.set('workingTimeSlots', workingTimeSlots);
};

const listingWorkingHoursReducer = (state = initialState, action) => {
  const { type, payload } = action;
  const saveInProgress = state.get('saveInProgress');

  switch (type) {
    case actionTypes.START_SAVING:
      return state.set('saveInProgress', true);
    case actionTypes.CHANGES_SAVED:
      return state.set('saveInProgress', false).set('saveFinished', true)
        .set('changes', false);
    case actionTypes.SAVING_FAILED:
      return state.set('saveInProgress', false);
    case actionTypes.DATA_CHANGED:
      return dataChanged(state);
    case actionTypes.DATA_LOADED:
      return dataLoaded(state, payload);
    case actionTypes.OPEN_EDIT_VIEW:
      return state.set('isOpen', true);
    case actionTypes.CLOSE_EDIT_VIEW:
      return saveInProgress ? state : clearState(state);
    default:
      return state;
  }
};

export default listingWorkingHoursReducer;
