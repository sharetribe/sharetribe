import * as actionTypes from '../constants/SearchPageConstants';
import FlashNotificationModel from '../models/FlashNotificationModel';

let nextMessageId = 1;

export const addFlashNotification = (type, content) => {
  const id = nextMessageId;
  nextMessageId += 1;
  return {
    type: actionTypes.FLASH_NOTIFICATION_ADD,
    payload: new FlashNotificationModel({
      id: `note_${id}`,
      type,
      content,
    }),
  };
};

export const removeFlashNotification = (id) => (
  {
    type: actionTypes.FLASH_NOTIFICATION_REMOVE,
    payload: { id },
  }
);
