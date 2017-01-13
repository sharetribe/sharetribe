/* global describe: false, it: false */
/* eslint-env mocha */
/* eslint-disable no-magic-numbers */

import { expect } from 'chai';
import { isSameDay } from 'react-dates';
import moment from 'moment';
import Immutable from 'immutable';
import * as actions from '../actions/ManageAvailabilityActions';
import reducer, { blockedDays, hasChanges, blockChanges, unblockChanges } from '../reducers/ManageAvailabilityReducer';

const UUID_V0 = '00000000-0000-0000-0000-000000000000';
const CURRENT_MONTH = moment().startOf('month');
const TODAY = moment().startOf('day');
const TOMORROW = TODAY.clone().add(1, 'days');
const DAY_AFTER_TOMORROW = TOMORROW.clone().add(1, 'days');
const DAY_AFTER_DAY_AFTER_TOMORROW = DAY_AFTER_TOMORROW.clone().add(1, 'days');

const applyActions = (reducerFn, state, actionList) => {
  if (actionList.size === 0) {
    return state;
  }
  const head = actionList.first();
  const tail = actionList.shift();
  return applyActions(reducerFn, reducerFn(state, head), tail);
};

describe('ManageAvailabilityReducer', () => {

  const stateEmpty = Immutable.Map({
    isOpen: true,
    visibleMonth: CURRENT_MONTH,
    bookings: Immutable.List(),
    blocks: Immutable.List(),
    changes: Immutable.List(),
    saveInProgress: false,
    marketplaceUuid: null,
    listingUuid: null,
  });

  const stateTodayBlocked = stateEmpty.set('blocks', Immutable.List([
    Immutable.Map({ id: UUID_V0, day: TODAY }),
  ]));
  const stateTodayBooked = stateEmpty.set('bookings', Immutable.List([TODAY]));

  describe('changes', () => {

    it('has no changes initially', () => {
      const state = stateEmpty;
      expect(state.get('blocks').size).to.equal(0);
      expect(state.get('changes').size).to.equal(0);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).size).to.equal(0);
    });

    it('has an initial block', () => {
      const state = stateTodayBlocked;
      expect(state.get('blocks').size).to.equal(1);
      expect(state.get('changes').size).to.equal(0);
      expect(hasChanges(state)).to.equal(false);
      const blocked = blockedDays(state);
      expect(blocked.size).to.equal(1);
      expect(isSameDay(blocked.first(), TODAY)).to.equal(true);
    });

    it('adds a single block', () => {
      const state = reducer(stateEmpty, actions.blockDay(TODAY));
      expect(state.get('blocks').size).to.equal(0);
      expect(state.get('changes').size).to.equal(1);
      expect(hasChanges(state)).to.equal(true);
      const blocked = blockedDays(state);
      expect(blocked.size).to.equal(1);
      expect(isSameDay(blocked.first(), TODAY)).to.equal(true);
    });

    it('adds a second block', () => {
      const state = reducer(stateTodayBlocked, actions.blockDay(TOMORROW));
      expect(state.get('blocks').size).to.equal(1);
      expect(state.get('changes').size).to.equal(1);
      expect(hasChanges(state)).to.equal(true);
      const blocked = blockedDays(state);
      expect(blocked.size).to.equal(2);
      expect(isSameDay(blocked.first(), TODAY)).to.equal(true);
      expect(isSameDay(blocked.last(), TOMORROW)).to.equal(true);
    });

    it('blocks and allows a day', () => {
      const state = applyActions(reducer, stateEmpty, Immutable.List([
        actions.blockDay(TODAY),
        actions.unblockDay(TODAY),
      ]));
      expect(state.get('blocks').size).to.equal(0);
      expect(state.get('changes').size).to.equal(2);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).size).to.equal(0);
    });

    it('allows an initially blocked day', () => {
      const state = reducer(stateTodayBlocked, actions.unblockDay(TODAY));
      expect(state.get('blocks').size).to.equal(1);
      expect(state.get('changes').size).to.equal(1);
      expect(hasChanges(state)).to.equal(true);
      expect(blockedDays(state).size).to.equal(0);
    });

    it('allows and blocks again an initially blocked day', () => {
      const state = applyActions(reducer, stateTodayBlocked, Immutable.List([
        actions.unblockDay(TODAY),
        actions.blockDay(TODAY),
      ]));

      expect(state.get('blocks').size).to.equal(1);
      expect(state.get('changes').size).to.equal(2);
      expect(hasChanges(state)).to.equal(false);
      const blocked = blockedDays(state);
      expect(blocked.size).to.equal(1);
      expect(isSameDay(blocked.first(), TODAY)).to.equal(true);
    });

    it('allows an initially allowed day', () => {
      const state = reducer(stateEmpty, actions.unblockDay(TODAY));
      expect(state.get('blocks').size).to.equal(0);
      expect(state.get('changes').size).to.equal(1);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).size).to.equal(0);
    });

    it('ignores an allow to a booked day', () => {
      const state = reducer(stateTodayBooked, actions.unblockDay(TODAY));
      expect(state.get('bookings').size).to.equal(1);
      expect(state.get('blocks').size).to.equal(0);
      expect(state.get('changes').size).to.equal(0);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).size).to.equal(0);
    });

    it('ignores a block to a booked day', () => {
      const state = reducer(stateTodayBooked, actions.blockDay(TODAY));
      expect(state.get('bookings').size).to.equal(1);
      expect(state.get('blocks').size).to.equal(0);
      expect(state.get('changes').size).to.equal(0);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).size).to.equal(0);
    });

  });

  describe('saving', () => {

    it('toggles the save in progress flag', () => {
      let state = stateEmpty;
      expect(state.get('saveInProgress')).to.equal(false);
      state = reducer(state, actions.startSaving());
      expect(state.get('saveInProgress')).to.equal(true);
      state = reducer(state, actions.changesSaved());
      expect(state.get('saveInProgress')).to.equal(false);
    });

    it('ignores allows and blocks while saving', () => {
      const initial = reducer(stateEmpty, actions.startSaving());
      const afterStartSaving = reducer(initial, actions.startSaving());
      const afterBlock = reducer(afterStartSaving, actions.blockDay(TODAY));
      expect(afterBlock.equals(afterStartSaving)).to.equal(true);
      const afterAllow = reducer(afterStartSaving, actions.unblockDay(TODAY));
      expect(afterAllow.equals(afterStartSaving)).to.equal(true);
    });

  });

  describe('changes', () => {

    describe('blockChanges', () => {

      it('should return no blocks with no changes', () => {
        const blocks = blockChanges(stateEmpty);
        expect(blocks.size).to.equal(0);
      });

      it('should return no blocks with only unblocks', () => {
        const state = reducer(stateTodayBlocked, actions.unblockDay(TODAY));
        const blocks = blockChanges(state);
        expect(blocks.size).to.equal(0);
      });

      it('should return no blocks with collapsed changes', () => {
        const state = applyActions(reducer, stateTodayBlocked, Immutable.List([
          actions.unblockDay(TODAY),
          actions.blockDay(TODAY),
        ]));
        const blocks = blockChanges(state);
        expect(blocks.size).to.equal(0);
      });

    });

    describe('unblockChanges', () => {

      it('should return no unblocks with no changes', () => {
        const unblocks = unblockChanges(stateEmpty);
        expect(unblocks.size).to.equal(0);
      });

      it('should return no unblocks with only blocks', () => {
        const state = reducer(stateEmpty, actions.blockDay(TODAY));
        const unblocks = unblockChanges(state);
        expect(unblocks.size).to.equal(0);
      });

      it('should return no unblocks with collapsed changes', () => {
        const state = applyActions(reducer, stateTodayBlocked, Immutable.List([
          actions.unblockDay(TODAY),
          actions.blockDay(TODAY),
        ]));
        const unblocks = unblockChanges(state);
        expect(unblocks.size).to.equal(0);
      });

    });

    it('should collect blocks and unblocks', () => {
      const state = applyActions(reducer, stateTodayBlocked, Immutable.List([
        actions.blockDay(TOMORROW),
        actions.unblockDay(TODAY),
        actions.blockDay(DAY_AFTER_TOMORROW),
      ]));
      const blocks = blockChanges(state);
      const unblocks = unblockChanges(state);
      expect(blocks.size).to.equal(2);
      expect(unblocks.size).to.equal(1);

      const block1 = blocks.first();
      const block2 = blocks.last();
      expect(isSameDay(block1.get('start'), TOMORROW)).to.equal(true);
      expect(isSameDay(block1.get('end'), DAY_AFTER_TOMORROW)).to.equal(true);
      expect(isSameDay(block2.get('start'), DAY_AFTER_TOMORROW)).to.equal(true);
      expect(isSameDay(block2.get('end'), DAY_AFTER_DAY_AFTER_TOMORROW)).to.equal(true);

      expect(unblocks.first()).to.equal(UUID_V0);
    });

  });

});
