/* global describe: false, it: false */
/* eslint-env mocha */
/* eslint-disable no-magic-numbers */

import { expect } from 'chai';
import { isSameDay } from 'react-dates';
import moment from 'moment';
import { Map, List } from 'immutable';
import * as actions from '../actions/ManageAvailabilityActions';
import reducer, { blockedDays, hasChanges } from '../reducers/ManageAvailabilityReducer';

const CURRENT_MONTH = moment().startOf('month');
const TODAY = moment();
const TOMORROW = moment(TODAY).add(1, 'days');

describe('ManageAvailabilityReducer', () => {

  describe('changes', () => {

    const stateEmpty = new Map({
      isOpen: true,
      visibleMonth: CURRENT_MONTH,
      reservedDays: new List(),
      blockedDays: new List(),
      changes: new List(),
    });

    const stateTodayBlocked = stateEmpty.set('blockedDays', new List([TODAY]));
    const stateTodayReserved = stateEmpty.set('reservedDays', new List([TODAY]));

    it('has no changes initially', () => {
      const state = stateEmpty;
      expect(state.get('blockedDays').size).to.equal(0);
      expect(state.get('changes').size).to.equal(0);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).size).to.equal(0);
    });

    it('has an initial block', () => {
      const state = stateTodayBlocked;
      expect(state.get('blockedDays').size).to.equal(1);
      expect(state.get('changes').size).to.equal(0);
      expect(hasChanges(state)).to.equal(false);
      const blocked = blockedDays(state);
      expect(blocked.size).to.equal(1);
      expect(isSameDay(blocked.first(), TODAY)).to.equal(true);
    });

    it('adds a single block', () => {
      const state = reducer(stateEmpty, actions.blockDay(TODAY));
      expect(state.get('blockedDays').size).to.equal(0);
      expect(state.get('changes').size).to.equal(1);
      expect(hasChanges(state)).to.equal(true);
      const blocked = blockedDays(state);
      expect(blocked.size).to.equal(1);
      expect(isSameDay(blocked.first(), TODAY)).to.equal(true);
    });

    it('adds a second block', () => {
      const state = reducer(stateTodayBlocked, actions.blockDay(TOMORROW));
      expect(state.get('blockedDays').size).to.equal(1);
      expect(state.get('changes').size).to.equal(1);
      expect(hasChanges(state)).to.equal(true);
      const blocked = blockedDays(state);
      expect(blocked.size).to.equal(2);
      expect(isSameDay(blocked.first(), TODAY)).to.equal(true);
      expect(isSameDay(blocked.last(), TOMORROW)).to.equal(true);
    });

    it('blocks and allows a day', () => {
      const blockAction = actions.blockDay(TODAY);
      const allowAction = actions.allowDay(TODAY);
      const state = reducer(reducer(stateEmpty, blockAction), allowAction);
      expect(state.get('blockedDays').size).to.equal(0);
      expect(state.get('changes').size).to.equal(2);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).size).to.equal(0);
    });

    it('allows an initially blocked day', () => {
      const state = reducer(stateTodayBlocked, actions.allowDay(TODAY));
      expect(state.get('blockedDays').size).to.equal(1);
      expect(state.get('changes').size).to.equal(1);
      expect(hasChanges(state)).to.equal(true);
      expect(blockedDays(state).size).to.equal(0);
    });

    it('allows and blocks again an initially blocked day', () => {
      const allowAction = actions.allowDay(TODAY);
      const blockAction = actions.blockDay(TODAY);
      const state = reducer(reducer(stateTodayBlocked, allowAction), blockAction);
      expect(state.get('blockedDays').size).to.equal(1);
      expect(state.get('changes').size).to.equal(2);
      expect(hasChanges(state)).to.equal(false);
      const blocked = blockedDays(state);
      expect(blocked.size).to.equal(1);
      expect(isSameDay(blocked.first(), TODAY)).to.equal(true);
    });

    it('allows an initially allowed day', () => {
      const state = reducer(stateEmpty, actions.allowDay(TODAY));
      expect(state.get('blockedDays').size).to.equal(0);
      expect(state.get('changes').size).to.equal(1);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).size).to.equal(0);
    });

    it('ignores an allow to a reserved day', () => {
      const state = reducer(stateTodayReserved, actions.allowDay(TODAY));
      expect(state.get('reservedDays').size).to.equal(1);
      expect(state.get('blockedDays').size).to.equal(0);
      expect(state.get('changes').size).to.equal(0);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).size).to.equal(0);
    });

    it('ignores a block to a reserved day', () => {
      const state = reducer(stateTodayReserved, actions.blockDay(TODAY));
      expect(state.get('reservedDays').size).to.equal(1);
      expect(state.get('blockedDays').size).to.equal(0);
      expect(state.get('changes').size).to.equal(0);
      expect(hasChanges(state)).to.equal(false);
      expect(blockedDays(state).size).to.equal(0);
    });

  });

});
