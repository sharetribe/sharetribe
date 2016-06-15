import r from 'r-dom';
import { storiesOf } from '@kadira/storybook';
import { storify } from '../../Styleguide/withProps';

import MenuItem from './MenuItem';

const containerStyle = { style: { minWidth: '200px', background: 'white' } };

storiesOf('MenuItem')
  .add('MenuItem not active', () => (
    r(storify(
      r(MenuItem, {
        href: 'http://example.com',
        content: 'Link',
        active: false,
        activeColor: '#a64c5d',
      }),
      containerStyle
    ))
  ))
  .add('MenuItem active', () => (
    r(storify(
      r(MenuItem, {
        href: 'http://example.com',
        content: 'Link',
        active: true,
        activeColor: '#a64c5d',
      }),
      containerStyle
    ))
  ))
  .add('MenuItem long content in mobile', () => (
      r(storify(
        r(MenuItem, {
          href: 'http://example.com',
          content: 'Lorem ipsum dolor sit amet consectetur adepisci velit',
          active: true,
          activeColor: '#a64c5d',
        }),
        { style: { minWidth: '200px', maxWidth: '230px', background: 'white' } },
        {}
      ))
    ));
