import Immutable from 'immutable';
import moment from 'moment';
import { isSameDay } from 'react-dates';
import * as actionTypes from '../constants/ManageAvailabilityConstants';

const initialState = Immutable.Map({
  isOpen: true,
  visibleMonth: moment()
    .startOf('month'),

  saveInProgress: false,
  saveFinished: false,

  loadedMonths: Immutable.Set(),

  triggerChanges: null,
  blocked_dates: [],
  initial_blocked_dates: [],
  booked_dates: [],
});

const includesDay = (days, day) =>
      days.some((d) => isSameDay(d, day));

const ACTION_UNBLOCK = 'unblock';
const ACTION_BLOCK = 'block';

const withChange = (state, action, day) => {
  if (includesDay(state.get('booked_dates'), day)) {
    return state;
  }
  const blocked_dates = state.get('blocked_dates');

  // console.log('before changes  ' + JSON.stringify(state.get('blocked_dates'), null, 4));
  const currentBlock = blocked_dates.find(
      (b) => isSameDay(b.blocked_at, day)
    );
  const destroy = (action === ACTION_UNBLOCK) ? '1' : null;
  if (currentBlock) {
    currentBlock.destroy = destroy;
  } else if (action === ACTION_BLOCK) {
    blocked_dates.push({ id: null, blocked_at: moment.utc(day) });
  }

  // force calendar rerender
  return state.set('triggerChanges', Math.random());
};

const mergeBlockedDates = (state, payload) => {
  const blocked_dates = state.get('blocked_dates');
  const initial_blocked_dates = state.get('initial_blocked_dates') || [];
  const update_blocked_dates = payload.blocked_dates.filter(
    (block) => !blocked_dates.find((x) => x.id === block.id));
  const update_initial_blocked_dates = [...payload.blocked_dates].filter(
    (block) => !initial_blocked_dates.find((x) => x.id === block.id));
  const loadedMonths = payload.loadedMonths;
  return state
    .set('blocked_dates', blocked_dates.concat(update_blocked_dates))
    .set('initial_blocked_dates', initial_blocked_dates.concat(update_initial_blocked_dates))
    .set('loadedMonths', state.get('loadedMonths').union(loadedMonths));
};

const mergeBookedDates = (state, payload) => {
  const booked_dates = state.get('booked_dates');
  const update = payload.filter((x) => booked_dates.indexOf(x) < 0);
  return state.set('booked_dates', booked_dates.concat(update));
};

export const hasChanges = (state) => {
  const blocked_dates = state.get('blocked_dates')
    .filter((x) => !(x.id === null && x.destroy === '1'));
  const initial_blocked_dates = state.get('initial_blocked_dates');
  if (blocked_dates && initial_blocked_dates) {
    if (blocked_dates.length !== initial_blocked_dates.length) {
      return true;
    } else {
      return blocked_dates.some((x) => x.destroy === '1');
    }
  }
  return false;
};

// Calculate currently blocked days from the fetched ones and the
// unsaved changes.
export const blockedDays = (state) => {
  const blocked_dates = state.get('blocked_dates');
  return blocked_dates
    .filter((x) => x.destroy !== '1')
    .map((x) => x.blocked_at);
};

const clearState = (state) =>
      state
      .set('isOpen', false)
      .set('bookings', Immutable.List())
      .set('blocks', Immutable.List())
      .set('changes', Immutable.List())
      .set('saveInProgress', false)
      .set('saveFinished', false)
      .set('loadedMonths', Immutable.Set())
      .set('visibleMonth', moment()
           .startOf('month'))
      .set('blocked_dates', [])
      .set('initial_blocked_dates', [])
      .set('booked_dates', []);

const manageAvailabilityReducer = (state = initialState, action) => {
  const { type, payload } = action;
  const saveInProgress = state.get('saveInProgress');

  switch (type) {
    case actionTypes.BLOCK_DAY:
      return saveInProgress ? state : withChange(state, ACTION_BLOCK, payload);
    case actionTypes.UNBLOCK_DAY:
      return saveInProgress ? state : withChange(state, ACTION_UNBLOCK, payload);
    case actionTypes.CHANGE_MONTH:
      return state.set('visibleMonth', payload);
    case actionTypes.START_SAVING:
      return state.set('saveInProgress', true);
    case actionTypes.CHANGES_SAVED:
      return state.set('saveInProgress', false).set('saveFinished', true);
    case actionTypes.SAVING_FAILED:
      return state.set('saveInProgress', false);
    case actionTypes.DATA_BLOCKED_DATES_LOADED:
      return mergeBlockedDates(state, payload);
    case actionTypes.DATA_BOOKED_DATES_LOADED:
      return mergeBookedDates(state, payload);
    case actionTypes.OPEN_EDIT_VIEW:
      return state.set('isOpen', true);
    case actionTypes.CLOSE_EDIT_VIEW:
      // Clean up store state, everything will be refetched when opened again.
      return saveInProgress ? state : clearState(state);
    default:
      return state;
  }
};

export default manageAvailabilityReducer;
