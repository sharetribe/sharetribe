import r from 'r-dom';
import Immutable from 'immutable';
import { storify } from '../../Styleguide/withProps';

import FlashNotification from './FlashNotification';
import FlashNotificationModel from '../../../models/FlashNotificationModel';

const { action, storiesOf } = storybookFacade;
const containerStyle = { style: { minWidth: '100px', background: 'white', height: '100px' } };


const actions = {
  removeFlashNotification: action('removeFlashNotification'),
};

storiesOf('General')
  .add('FlashNotification: basic state', () => (
    r(storify(
      r(FlashNotification,
        {
          actions,
          messages: new Immutable.List([
            new FlashNotificationModel({
              id: 0,
              type: 'notice',
              content: 'Notice this message with a <a href="link">link</a>',
              isRead: false,
            }),
            new FlashNotificationModel({
              id: 1,
              type: 'warning',
              content: 'Warning doesn\'t have any special formatting',
              isRead: false,
            }),
            new FlashNotificationModel({
              id: 2,
              type: 'error',
              content: 'This is an error flash from the system',
              isRead: false,
            }),
          ]),
        }
      ), containerStyle
    ))
  ));
