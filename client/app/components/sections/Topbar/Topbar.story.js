import { storiesOf, action } from '@kadira/storybook';
import r from 'r-dom';
import withProps, { storify, defaultRailsContext } from '../../Styleguide/withProps';

import Topbar from './Topbar';
const containerStyle = { style: { minWidth: '600px', background: 'white' } };

const baseProps = {
  logo: {
    href: 'http://example.com',
    text: 'Bikerrrs',
    image: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
    image_highres: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
  },
  search: {
    mode: 'keyword-and-location',
    keyword_placeholder: 'Search...',
    location_placeholder: 'Location',
    onSubmit: action('submitting search'),
  },
  avatarDropdown: {
    customColor: '#EE4',
    actions: {
      inboxAction: action('clicked inbox'),
      profileAction: action('clicked profile'),
      settingsAction: action('clicked settings'),
      adminDashboardAction: action('clicked admin dashboard'),
      logoutAction: action('clicked logout'),
    },
    avatar: {
      imageHeight: '44px',
      image: 'https://www.gravatar.com/avatar/d0865b2133d55fd507639a0fd1692b9a',
      onClick: () => {
        action('clicked avatar');
      },
    },
  },
};

storiesOf('Top bar')
  .add('Basic state', () => (
    withProps(Topbar, baseProps)))
  .add('Text logo', () => (
    withProps(Topbar, { ...baseProps, logo: {
      href: 'http://example.com',
      text: 'My Marketplace',
    } })))
  .add('Long text logo', () => (
    withProps(Topbar, { ...baseProps, logo: {
      href: 'http://example.com',
      text: 'My Marketplace with a looong name',
    } })))
  .add('With keyword search', () => (
    withProps(Topbar, { ...baseProps, search: { mode: 'keyword' } })))
  .add('With location search', () => (
    withProps(Topbar, {
      logo: {
        href: 'http://example.com',
        text: 'Bikerrrs',
        image: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
        image_highres: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
      },
      search: {
        mode: 'location',
        keyword_placeholder: 'Search...',
        location_placeholder: 'Location',
      },
    })))
  .add('With keyword and location search', () => (
    withProps(Topbar, {
      logo: {
        href: 'http://example.com',
        text: 'Bikerrrs',
        image: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
        image_highres: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
      },
      search: {
        mode: 'keyword-and-location',
        keyword_placeholder: 'Search...',
        location_placeholder: 'Location',
      },
    })))
    .add('Menu', () => (
      r(storify(
        r(Topbar, {
          logo: {
            href: 'http://example.com',
            text: 'Bikerrrs',
            image: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
          },
          search_mode: 'keyword-and-location',
          search_keyword_placeholder: 'Search...',
          search_location_placeholder: 'Location',
          menu: {
            isOpen: false,
            name: 'Menu',
            identifier: 'Menu',
            menuLabelType: 'menu',
            content: [
              {
                type: 'menuitem',
                href: 'http://example.com#about',
                content: 'About',
                active: true,
                activeColor: '#43A5CC',
              },
              {
                type: 'menuitem',
                href: 'http://example.com#link',
                content: 'Link',
                active: false,
                activeColor: '#43A5CC',
              },
              {
                type: 'menuitem',
                href: 'http://example.com#link2',
                content: 'Link2',
                active: false,
                activeColor: '#43A5CC',
              },
              {
                type: 'menuitem',
                href: 'http://example.com#longlink',
                content: 'Lorem ipsum dolor sit amet consectetur adepisci velit',
                active: false,
                activeColor: '#43A5CC',
              },
            ],
          },
          languageMenu: {
            isOpen: false,
            name: 'En',
            identifier: 'LanguageMenu',
            menuLabelType: 'menu',
            content: [
              {
                type: 'menuitem',
                href: 'http://example.com#en',
                content: 'English',
                active: true,
                activeColor: '#43A5CC',
              },
              {
                type: 'menuitem',
                href: 'http://example.com#fi',
                content: 'Finnish',
                active: false,
                activeColor: '#43A5CC',
              },
              {
                type: 'menuitem',
                href: 'http://example.com#fr',
                content: 'French',
                active: false,
                activeColor: '#43A5CC',
              },
            ],
          },
        }),
        containerStyle
      ))
  ));
