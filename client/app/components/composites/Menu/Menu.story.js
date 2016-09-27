import r from 'r-dom';
import { storify, defaultRailsContext } from '../../Styleguide/withProps';

import Menu from './Menu';

const { storiesOf } = storybookFacade;
const containerStyle = { style: { minWidth: '100px', background: 'white' } };

storiesOf('Top bar')
  .add('Menu: basic desktop', () => (
      r(storify(
        r(Menu, Object.assign({},
          {
            name: 'Menu',
            identifier: 'Menu',
            menuLabelType: 'menu',
            content: [
              {
                type: 'menuitem',
                href: 'http://example.com#1',
                content: 'Link',
                active: false,
                activeColor: '#a64c5d',
              },
              {
                type: 'menuitem',
                href: 'http://example.com#2',
                content: 'Link2',
                active: true,
                activeColor: '#a64c5d',
              },
              {
                type: 'menuitem',
                href: 'http://example.com',
                content: 'Lorem ipsum dolor sit amet consectetur adepisci velit',
                active: false,
                activeColor: '#a64c5d',
              },
            ],
          },
          {
            marketplaceContext: defaultRailsContext,
          }
        )),
        containerStyle
      ))
  ));
