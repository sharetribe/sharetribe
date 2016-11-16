import { expect } from 'chai';
import Immutable from 'immutable';
import _ from 'lodash';

import * as actions from '../actions/FlashNotificationActions';
import * as types from '../constants/SearchPageConstants';
import reducer from '../reducers/FlashNotificationReducer';

import FlashNotificationModel from '../models/FlashNotificationModel';


describe('FlashNotification', () => {
  describe('actions', () => {
    it('should create an action to add a notification', () => {
      const content = 'Error message';
      const type = 'error';

      const expectedAction = {
        type: types.FLASH_NOTIFICATION_ADD,
        payload: new FlashNotificationModel({
          id: 'note_1',
          type,
          content,
          isRead: false,
        }),
      };

      expect(actions.addFlashNotification(type, content).payload.toString()).to.equal(expectedAction.payload.toString());
    });

    it('should create an action to remove a notification', () => {
      const expectedAction = {
        type: types.FLASH_NOTIFICATION_REMOVE,
        payload: {
          id: 1,
        },
      };

      expect(
        _.isEqual(actions.removeFlashNotification(1), expectedAction)
      ).to.equal(true);
    });
  });

  describe('reducer', () => {
    it('should return the initial state', () => {
      const initial = reducer(undefined, {}); // eslint-disable-line no-undefined
      expect(initial.flashMessages).to.be.an.instanceof(Immutable.List);
      expect(Immutable.is(initial.flashMessages, new Immutable.List())).to.equal(true);
    });

    it('should handle FLASH_NOTIFICATION_ADD', () => {
      const flashNote = new FlashNotificationModel({
        id: 0,
        type: 'error',
        content: 'Run the tests',
        isRead: false,
      });

      const reduced = reducer(new Immutable.List(), {
        type: types.FLASH_NOTIFICATION_ADD,
        payload: flashNote,
      });

      const reducedWithInitialContent = reducer(new Immutable.List([flashNote]), {
        type: types.FLASH_NOTIFICATION_ADD,
        payload: flashNote,
      });

      expect(Immutable.is(reduced, new Immutable.List([flashNote]))).to.equal(true);
      expect(
        Immutable.is(reducedWithInitialContent, new Immutable.List([flashNote, flashNote]))
      ).to.equal(true);
    });
  });
});
