import { storiesOf, action } from '@kadira/storybook';
import withProps from '../../Styleguide/withProps';

import Topbar from './Topbar';

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
    withProps(Topbar, { ...baseProps, search: { mode: 'location' } })));
