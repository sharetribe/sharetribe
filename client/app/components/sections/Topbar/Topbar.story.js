import { storiesOf, action } from '@kadira/storybook';
import r from 'r-dom';
import { storify } from '../../Styleguide/withProps';

import Topbar from './Topbar';

const containerStyle = { style: { minWidth: '600px', background: 'white' } };

const fakeRoute = () => '#';

const baseProps = {
  routes: {
    person_inbox_path: fakeRoute,
    person_path: fakeRoute,
    person_settings_path: fakeRoute,
    logout_path: fakeRoute,
    admin_path: fakeRoute,
  },
  logo: {
    href: 'http://example.com',
    text: 'Bikerrrs',
    image: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
    image_highres: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
  },
  search: {
    mode: 'keyword_and_location',
    keyword_placeholder: 'Search...',
    location_placeholder: 'Location',
    onSubmit: action('submitting search'),
  },
  search_path: '#',
  menu: {
    limit_priority_links: null,
    links: [
      {
        link: 'http://example.com#about',
        title: 'About',
        priority: 0,
      },
      {
        link: 'http://suspicious.com#link',
        title: 'External',
        external: true,
        priority: 1,
      },
      {
        link: 'http://example.com#link2',
        title: 'Link2',
        priority: 2,
      },
      {
        link: 'http://example.com#longlink',
        title: 'Lorem ipsum dolor sit amet consectetur adepisci velit',
        priority: 3,
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
      {
        change_locale_uri: 'http://example.com#de',
        locale_name: 'German',
        locale_ident: 'de',
      },
    ],
  },
  avatarDropdown: {
    actions: {
      inboxAction: action('clicked inbox'),
      profileAction: action('clicked profile'),
      settingsAction: action('clicked settings'),
      adminDashboardAction: action('clicked admin dashboard'),
      logoutAction: action('clicked logout'),
    },
    avatar: {
      image: 'https://www.gravatar.com/avatar/d0865b2133d55fd507639a0fd1692b9a',
    },
  },
  newListingButton: {
    text: 'Post a new listing',
  },
  i18n: {
    locale: 'en',
    defaultLocale: 'en',
  },
  marketplace: {
    marketplace_color1: '#64A',
    location: '/',
  },
  user: {
    loggedInUsername: 'foo',
    isAdmin: true,
  },
};

const loggedOut = (props) => ({
  ...props,
  user: {
    loggedInUsername: null,
    isAdmin: false,
  },
});

const storifyTopbar = (props) => r(storify(r(Topbar, props)), containerStyle);

storiesOf('Top bar')
  .add('Basic state', () => (
    storifyTopbar(baseProps)))
  .add('Empty state', () => (
    storifyTopbar({
      logo: baseProps.logo,
      marketplace: {
        location: '/',
      },
      routes: baseProps.routes,
      search_path: baseProps.search_path,
    })))
  .add('Logged out', () => (
    storifyTopbar(loggedOut(baseProps))))
  .add('Text logo', () => (
    storifyTopbar({ ...baseProps, logo: {
      href: 'http://example.com',
      text: 'My Marketplace',
    } })))
  .add('Long text logo', () => (
    storifyTopbar({ ...baseProps, logo: {
      href: 'http://example.com',
      text: 'My Marketplace with a looong name',
    } })))
  .add('Without search', () => (
    storifyTopbar({ ...baseProps, search: null })))
  .add('Without search, logged out', () => (
    storifyTopbar({ ...loggedOut(baseProps), search: null })))
  .add('With keyword search', () => (
    storifyTopbar({ ...baseProps, search: { mode: 'keyword' } })))
  .add('With location search', () => (
    storifyTopbar({ ...baseProps, search: { mode: 'location' } })))
  .add('With keyword and location search', () => (
    storifyTopbar({ ...baseProps, search: { mode: 'keyword_and_location' } })))
  .add('Logged in as admin', () => (
    storifyTopbar({ ...baseProps, isAdmin: true })));
