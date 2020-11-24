import Immutable from 'immutable';

const FlashNotificationModel = Immutable.Record({
  id: 0,
  type: 'notice',
  content: 'message',
  isRead: false,
});

export default FlashNotificationModel;
