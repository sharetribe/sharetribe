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
  .add('Empty state', () => (
    withProps(Topbar, { logo: baseProps.logo })))
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
    .add('Menu on About page', () => (
      r(storify(
        r(Topbar, Object.assign({}, {
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
          menu: {
            links: [
              {
                link: 'http://example.com#about',
                title: 'About',
              },
              {
                link: 'http://example.com#link',
                title: 'Link',
              },
              {
                link: 'http://example.com#link2',
                title: 'Link2',
              },
              {
                link: 'http://example.com#longlink',
                title: 'Lorem ipsum dolor sit amet consectetur adepisci velit',
              },
            ],
          },
          locales: {
            current_locale: 'en',
            current_locale_ident: 'en',
            available_locales: [
              {
                change_locale_uri: 'http://example.com#en',
                locale_name: 'English',
                locale_ident: 'en',
              },
              {
                change_locale_uri: 'http://example.com#fi',
                locale_name: 'Suomi',
                locale_ident: 'fi',
              },
              {
                change_locale_uri: 'http://example.com#fr',
                locale_name: 'French',
                locale_ident: 'fr',
              },
            ],
          },
        }, {
          railsContext: defaultRailsContext,
        })),
        containerStyle
      ))
  ));
