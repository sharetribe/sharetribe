import r from 'r-dom';
import { storify } from '../../Styleguide/withProps';

import MenuItem from './MenuItem';

const { storiesOf } = storybookFacade;
const containerStyle = { style: { minWidth: '200px', background: 'white' } };

storiesOf('Top bar')
  .add('MenuItem: not active', () => (
    r(storify(
      r(MenuItem, {
        href: 'http://example.com',
        content: 'Link',
        active: false,
        activeColor: '#a64c5d',
        type: 'menuitem',
        index: 1,
      }),
      containerStyle
    ))
  ))
  .add('MenuItem: active', () => (
    r(storify(
      r(MenuItem, {
        href: 'http://example.com',
        content: 'Link',
        active: true,
        activeColor: '#a64c5d',
        type: 'menuitem',
        index: 1,
      }),
      containerStyle
    ))
  ))
  .add('MenuItem: long content in mobile', () => (
      r(storify(
        r(MenuItem, {
          href: 'http://example.com',
          content: 'Lorem ipsum dolor sit amet consectetur adepisci velit',
          active: true,
          activeColor: '#a64c5d',
          type: 'menuitem',
          index: 1,
        }),
        { style: { minWidth: '200px', maxWidth: '230px', background: 'white' } },
        {}
      ))
    ));
