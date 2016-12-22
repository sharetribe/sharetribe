import Immutable from 'immutable';
import moment from 'moment';
import { isSameDay } from 'react-dates';
import * as actionTypes from '../constants/ManageAvailabilityConstants';
import { expandRange } from '../utils/moment';

const initialState = Immutable.Map({
  isOpen: true,
  visibleMonth: moment()
    .startOf('month'),

  // List of days that buyers have booked. These cannot be blocked.
  bookings: Immutable.List(),

  // List of Maps with `id` and `day` keys indicating days that are
  // blocked and already saved to the API.
  blocks: Immutable.List(),

  // List of changes with `action` (String) and `day` (moment
  // instance) keys. Whenever the user blocks/unblocks a day, a change
  // is added to this list. The actual changes for the UI and the API
  // are calculated by going through this list to see the final values
  // for each day and comparing those to the blocked days above.
  changes: Immutable.List(),

  saveInProgress: false,
  saveFinished: false,

  marketplaceUuid: null,

  listingUuid: null,

  loadedMonths: Immutable.Set(),
});

const includesDay = (days, day) =>
      days.some((d) => isSameDay(d, day));

const ACTION_UNBLOCK = 'unblock';
const ACTION_BLOCK = 'block';

const withChange = (state, action, day) => {
  if (includesDay(state.get('bookings'), day)) {
    // Changes to reserved days ignored
    return state;
  }
  let id = null;

  if (action === ACTION_UNBLOCK) {
    const currentBlock = state.get('blocks').find(
      (b) => isSameDay(b.get('day'), day)
    );
    if (currentBlock && currentBlock.get('id')) {
      id = currentBlock.get('id');
    }
  }

  const change = Immutable.Map({ id, action, day });
  return state.set('changes', state.get('changes').push(change));
};

const ranges = (bookings) =>
  bookings.map((b) => (Immutable.Map({
    start: moment(b.getIn([':attributes', ':start'])),
    end: moment(b.getIn([':attributes', ':end'])),
  })));

const expandRanges = (dateRanges) =>
  dateRanges.flatMap((range) => {
    const start = range.get('start');
    const end = range.get('end');

    return expandRange(start, end, 'days');
  });

const mergeNovelty = (state, novelty) => {
  const blocks = novelty.get('blocks').map((b) => Immutable.Map({
    id: b.get(':id'),
    day: moment(b.getIn([':attributes', ':start'])),
  }));

  const bookings = expandRanges(ranges(novelty.get('bookings')));
  const loadedMonths = novelty.get('loadedMonths');

  return state.set('bookings', state.get('bookings').concat(bookings))
              .set('blocks', state.get('blocks').concat(blocks))
              .set('loadedMonths', state.get('loadedMonths').union(loadedMonths));
};

// Calculate all unique changes to the original blocked days
export const compressedChanges = (state) => {
  const changes = state.get('changes');

  const isSameDayChange = (c1) => (c2) =>
        isSameDay(c1.get('day'), c2.get('day'));

  // Compress to only take the final state of a single day into account
  const compressed = changes.reduce((result, change) => {
    const existingChange = result.find(isSameDayChange(change));

    if (existingChange && existingChange.get('action') !== change.get('action')) {
      return result.filterNot(isSameDayChange(change)).push(change);
    } else if (!existingChange) {
      return result.push(change);
    }
    return result;
  }, Immutable.List());

  const blocks = state.get('blocks').map((b) => b.get('day'));

  // Only include changes to the original blocked days
  return compressed.filter((c) => {
    const isBlock = c.get('action') === ACTION_BLOCK;
    const alreadyBlocked = includesDay(blocks, c.get('day'));

    // A change is only considered if it is a block that isn't already
    // blocked or if it is an unblock to a day that is already blocked.
    return (isBlock && !alreadyBlocked) || (!isBlock && alreadyBlocked);
  });
};

export const hasChanges = (state) =>
  compressedChanges(state).size > 0;

export const blockChanges = (state) =>
  compressedChanges(state).reduce((blocks, change) => {
    if (change.get('action') === ACTION_UNBLOCK) {
      return blocks;
    }
    const day = change.get('day');
    const block = Immutable.Map({
      start: day.clone().startOf('day'),
      end: day.clone()
        .add(1, 'days')
        .startOf('day'),
    });
    return blocks.push(block);
  }, Immutable.List());

export const unblockChanges = (state) =>
  compressedChanges(state).reduce((unblocks, change) => {
    if (change.get('action') === ACTION_BLOCK) {
      return unblocks;
    }
    if (!change.get('id')) {
      throw new Error('No id in unblock');
    }
    return unblocks.push(change.get('id'));
  }, Immutable.List());

// Calculate currently blocked days from the fetched ones and the
// unsaved changes.
export const blockedDays = (state) => {
  const changes = compressedChanges(state);

  // Collect lists of day instances for blocks and unblocks
  const splitChanges = changes.reduce((result, c) => {
    const isBlock = c.get('action') === ACTION_BLOCK;
    const day = c.get('day');
    return isBlock ?
      result.set('blocks', result.get('blocks').push(day)) :
      result.set('unblocks', result.get('unblocks').push(day));
  }, Immutable.Map({
    blocks: Immutable.List(),
    unblocks: Immutable.List(),
  }));

  const blocks = splitChanges.get('blocks');
  const unblocks = splitChanges.get('unblocks');

  return state
    .get('blocks')
    .map((b) => b.get('day'))
    .concat(blocks)
    .filter((d) => !includesDay(unblocks, d));
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
           .startOf('month'));

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
    case actionTypes.DATA_LOADED:
      return mergeNovelty(state, payload);
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
