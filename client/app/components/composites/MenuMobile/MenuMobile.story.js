import r from 'r-dom';
import { storiesOf } from '@kadira/storybook';
import { storify, defaultRailsContext } from '../../Styleguide/withProps';

import MenuMobile from './MenuMobile';

const containerStyle = { style: { minWidth: '100px', background: 'white', height: '768px' } };

storiesOf('MenuMobile')
  .add('Basic state ', () => (
      r(storify(
        r(MenuMobile,
          {
            marketplaceContext: defaultRailsContext,
            name: 'Menu',
            color: '#a64c5d',
            identifier: 'menu',
            menuLinksTitle: 'menu links',
            menuLinks: [
              {
                type: 'menuitem',
                href: '#',
                content: 'Link',
                active: false,
                activeColor: '#a64c5d',
              },
              {
                type: 'menuitem',
                href: '#',
                content: 'Link2',
                active: true,
                activeColor: '#a64c5d',
              },
              {
                type: 'menuitem',
                href: '#',
                content: 'Lorem ipsum dolor sit amet consectetur adepisci velit',
                active: false,
                activeColor: '#a64c5d',
                external: true,
              },
            ],
            userLinksTitle: 'User',
            userLinks: [
              {
                type: 'menuitem',
                href: '#',
                content: 'Inbox',
                active: false,
                activeColor: '#a64c5d',
              },
              {
                type: 'menuitem',
                href: '#',
                content: 'Profile',
                active: true,
                activeColor: '#a64c5d',
              },
              {
                type: 'menuitem',
                href: '#',
                content: 'Manage Listings',
                active: false,
                activeColor: '#a64c5d',
              },
              {
                type: 'menuitem',
                href: '#',
                content: 'Settings',
                active: false,
                activeColor: '#a64c5d',
              },
              {
                type: 'menuitem',
                href: '#',
                content: 'Logout',
                active: false,
                activeColor: '#a64c5d',
              },
            ],
            languages: {
              name: 'Language',
              color: '#a64c5d',
              links: [
                {
                  href: '#',
                  content: 'English',
                  active: true,
                  activeColor: '#a64c5d',
                },
                {
                  href: '#',
                  content: 'German',
                  active: false,
                  activeColor: '#a64c5d',
                },
                {
                  href: '#',
                  content: 'Spanish',
                  active: false,
                  activeColor: '#a64c5d',
                },
                {
                  href: '#',
                  content: 'Finnish',
                  active: false,
                  activeColor: '#a64c5d',
                },
              ],
            },
            avatar: {
              image: 'https://www.gravatar.com/avatar/d0865b2133d55fd507639a0fd1692b9a',
              url: '#',
            },
            newListingButton: {
              text: 'Post a new listing',
              url: 'www.example.com/post',
              mobileLayoutOnly: true,
            },
          }
        ),
        containerStyle
      ))
  ));
