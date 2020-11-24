/* global describe: false, it: false */
/* eslint-env mocha */
/* eslint-disable no-magic-numbers */

import { expect } from 'chai';
import { isSameDay } from 'react-dates';
import moment from 'moment';
import Immutable from 'immutable';
import * as actions from '../actions/ManageAvailabilityActions';
import reducer, { blockedDays, hasChanges } from '../reducers/ManageAvailabilityReducer';

const CURRENT_MONTH = moment().startOf('month');
const TODAY = moment().startOf('day');
const TOMORROW = TODAY.clone().add(1, 'days');
const DAY_AFTER_TOMORROW = TOMORROW.clone().add(1, 'days');

const applyActions = (reducerFn, state, actionList) => {
  if (actionList.size === 0) {
    return state;
  }
  const head = actionList.first();
  const tail = actionList.shift();
  return applyActions(reducerFn, reducerFn(state, head), tail);
};

describe('ManageAvailabilityReducer', () => {

  const stateEmpty = () => {
    const state = {
      isOpen: true,
      visibleMonth: CURRENT_MONTH,
      saveInProgress: false,
      triggerChanges: null,
    };
    state.blocked_dates = [];
    state.initial_blocked_dates = [];
    state.booked_dates = [];
    return Immutable.Map(state);
  };

  const stateTodayBlocked = () => stateEmpty()
    .set('blocked_dates', [{ id: 1, blocked_at: TODAY }])
    .set('initial_blocked_dates', [{ id: 1, blocked_at: TODAY }]);

  const stateTodayBooked = () => stateEmpty().set('booked_dates', [TODAY]);

  describe('changes', () => {

    it('has no changes initially', () => {
      const state = stateEmpty();
      expect(state.get('initial_blocked_dates').length).to.equal(0);
      expect(state.get('blocked_dates').length).to.equal(0);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).length).to.equal(0);
    });

    it('has an initial block', () => {
      const state = stateTodayBlocked();
      expect(state.get('initial_blocked_dates').length).to.equal(1);
      expect(state.get('blocked_dates').length).to.equal(1);
      expect(hasChanges(state)).to.equal(false);
      const blocked = blockedDays(state);
      expect(blocked.length).to.equal(1);
      expect(isSameDay(blocked[0], TODAY)).to.equal(true);
    });

    it('adds a single block', () => {
      const state = reducer(stateEmpty(), actions.blockDay(TODAY));
      const blocked_dates = state.get('blocked_dates');
      expect(blocked_dates.length).to.equal(1);
      expect(blocked_dates[0].id).to.equal(null);
      expect(isSameDay(blocked_dates[0].blocked_at, TODAY)).to.equal(true);
      expect(hasChanges(state)).to.equal(true);
      const blocked = blockedDays(state);
      expect(blocked.length).to.equal(1);
      expect(isSameDay(blocked[0], TODAY)).to.equal(true);
    });

    it('adds a second block', () => {
      const state = reducer(stateTodayBlocked(), actions.blockDay(TOMORROW));
      expect(state.get('initial_blocked_dates').length).to.equal(1);
      expect(state.get('blocked_dates').length).to.equal(2);
      expect(hasChanges(state)).to.equal(true);
      const blocked = blockedDays(state);
      expect(blocked.length).to.equal(2);
      expect(isSameDay(blocked[0], TODAY)).to.equal(true);
      expect(isSameDay(blocked[1], TOMORROW)).to.equal(true);
    });

    it('blocks and allows a day', () => {
      const state = applyActions(reducer, stateEmpty(), Immutable.List([
        actions.blockDay(TODAY),
        actions.unblockDay(TODAY),
      ]));
      expect(state.get('initial_blocked_dates').length).to.equal(0);
      expect(state.get('blocked_dates').length).to.equal(1);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).length).to.equal(0);
    });

    it('allows an initially blocked day', () => {
      const state = reducer(stateTodayBlocked(), actions.unblockDay(TODAY));
      expect(state.get('initial_blocked_dates').length).to.equal(1);
      expect(state.get('blocked_dates').length).to.equal(1);
      expect(hasChanges(state)).to.equal(true);
      expect(blockedDays(state).length).to.equal(0);
    });

    it('allows and blocks again an initially blocked day', () => {
      const state = applyActions(reducer, stateTodayBlocked(), Immutable.List([
        actions.unblockDay(TODAY),
        actions.blockDay(TODAY),
      ]));

      expect(state.get('initial_blocked_dates').length).to.equal(1);
      expect(state.get('blocked_dates').length).to.equal(1);
      expect(hasChanges(state)).to.equal(false);
      const blocked = blockedDays(state);
      expect(blocked.length).to.equal(1);
      expect(isSameDay(blocked[0], TODAY)).to.equal(true);
    });

    it('allows an initially allowed day', () => {
      const state = reducer(stateEmpty(), actions.unblockDay(TODAY));
      expect(state.get('initial_blocked_dates').length).to.equal(0);
      expect(state.get('blocked_dates').length).to.equal(0);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).length).to.equal(0);
    });

    it('ignores an allow to a booked day', () => {
      const state = reducer(stateTodayBooked(), actions.unblockDay(TODAY));
      expect(state.get('booked_dates').length).to.equal(1);
      expect(state.get('initial_blocked_dates').length).to.equal(0);
      expect(state.get('blocked_dates').length).to.equal(0);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).length).to.equal(0);
    });

    it('ignores a block to a booked day', () => {
      const state = reducer(stateTodayBooked(), actions.blockDay(TODAY));
      expect(state.get('booked_dates').length).to.equal(1);
      expect(state.get('initial_blocked_dates').length).to.equal(0);
      expect(state.get('blocked_dates').length).to.equal(0);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).length).to.equal(0);
    });

  });

  describe('saving', () => {

    it('toggles the save in progress flag', () => {
      let state = stateEmpty();
      expect(state.get('saveInProgress')).to.equal(false);
      state = reducer(state, actions.startSaving());
      expect(state.get('saveInProgress')).to.equal(true);
      state = reducer(state, actions.changesSaved());
      expect(state.get('saveInProgress')).to.equal(false);
    });

    it('ignores allows and blocks while saving', () => {
      const initial = reducer(stateEmpty(), actions.startSaving());
      const afterStartSaving = reducer(initial, actions.startSaving());
      const afterBlock = reducer(afterStartSaving, actions.blockDay(TODAY));
      expect(afterBlock.equals(afterStartSaving)).to.equal(true);
      const afterAllow = reducer(afterStartSaving, actions.unblockDay(TODAY));
      expect(afterAllow.equals(afterStartSaving)).to.equal(true);
    });

  });

  describe('changes', () => {


    it('should collect blocks and unblocks', () => {
      const state = applyActions(reducer, stateTodayBlocked(), Immutable.List([
        actions.blockDay(TOMORROW),
        actions.unblockDay(TODAY),
        actions.blockDay(DAY_AFTER_TOMORROW),
      ]));
      expect(state.get('initial_blocked_dates').length).to.equal(1);
      const blocked_dates = state.get('blocked_dates');
      expect(blocked_dates.length).to.equal(3);

      const unblock = blocked_dates.find((x) => x.destroy === '1');
      expect(isSameDay(unblock.blocked_at, TODAY)).to.equal(true);


      expect(blocked_dates[1].id).to.equal(null);
      expect(isSameDay(blocked_dates[1].blocked_at, TOMORROW)).to.equal(true);
      expect(blocked_dates[2].id).to.equal(null);
      expect(isSameDay(blocked_dates[2].blocked_at, DAY_AFTER_TOMORROW)).to.equal(true);
    });

  });

});
