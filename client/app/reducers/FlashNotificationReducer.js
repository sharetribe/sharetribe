import Immutable from 'immutable';
import FlashNotificationModel from '../models/FlashNotificationModel';
import * as actionTypes from '../constants/SearchPageConstants';

const initialState = {
  flashMessages: new Immutable.List(),
};

const flashNotifications = (state = initialState, action) => {
  const { type, payload } = action;
  switch (type) {
    case actionTypes.FLASH_NOTIFICATION_ADD:
      if (!state.find((n) => n.content === payload.content && !n.isRead)) {
        return state.push(new FlashNotificationModel({
          id: payload.id,
          type: payload.type,
          content: payload.content,
          isRead: false,
        }));
      }
      return state;

    case actionTypes.FLASH_NOTIFICATION_REMOVE:
      return state.update(
        state.findIndex((msg) => msg.id === payload.id),
        (msg) => msg.set('isRead', true)
      );

    default:
      return state;
  }
};

export default flashNotifications;
