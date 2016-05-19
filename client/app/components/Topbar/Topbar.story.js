import { storiesOf } from '@kadira/storybook';
import withProps from '../Styleguide/withProps';
import r from 'r-dom';

import Topbar from './Topbar';

storiesOf('Top bar')
  .add('Picture logo 1', () => (
    withProps(Topbar, { logo: {
      href: 'http://example.com',
      image: 'https://sharetribe.s3.amazonaws.com/images/communities/wide_logos/1194/header_highres/The_Quiver_desktop.png?1414049649',
    } })))
  .add('Picture logo 2', () => (
    withProps(Topbar, { logo: {
      href: 'http://example.com',
      image: 'http://placehold.it/350x150',
    } })))
  .add('Text logo 1', () => (
    withProps(Topbar, { logo: {
      href: 'http://example.com',
      text: 'My Marketplace',
    } })));
