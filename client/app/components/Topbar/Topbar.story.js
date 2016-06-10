import { storiesOf } from '@kadira/storybook';
import withProps from '../Styleguide/withProps';

import Topbar from './Topbar';

storiesOf('Top bar')
  .add('Picture logo 1', () => (
    withProps(Topbar, {
      logo: {
        href: 'http://example.com',
        text: 'Bikerrrs',
        image: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
      },
    })))
  .add('Picture logo 2', () => (
    withProps(Topbar, {
      logo: {
        href: 'http://example.com',
        text: 'Placeholder marketplace',
        image: 'http://placehold.it/350x150',
      },
    })))
  .add('Short text logo', () => (
    withProps(Topbar, {
      logo: {
        href: 'http://example.com',
        text: 'My Marketplace',
      },
    })))
  .add('Long text logo', () => (
    withProps(Topbar, {
      logo: {
        href: 'http://example.com',
        text: 'My Marketplace with a long name',
      },
    })))
  .add('With keyword search', () => (
    withProps(Topbar, {
      logo: {
        href: 'http://example.com',
        text: 'Bikerrrs',
        image: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
      },
      search_mode: 'keyword',
      search_keyword_placeholder: 'Search...',
      search_location_placeholder: 'Location',
    })))
  .add('With location search', () => (
    withProps(Topbar, {
      logo: {
        href: 'http://example.com',
        text: 'Bikerrrs',
        image: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
      },
      search_mode: 'location',
      search_keyword_placeholder: 'Search...',
      search_location_placeholder: 'Location',
    })))
  .add('With keyword and location search', () => (
    withProps(Topbar, {
      logo: {
        href: 'http://example.com',
        text: 'Bikerrrs',
        image: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
      },
      search_mode: 'keyword-and-location',
      search_keyword_placeholder: 'Search...',
      search_location_placeholder: 'Location',
    })));
