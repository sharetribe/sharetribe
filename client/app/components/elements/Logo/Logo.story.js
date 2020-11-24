import withProps from '../../Styleguide/withProps';
import r from 'r-dom';

import Logo from './Logo';

const { storiesOf } = storybookFacade;

storiesOf('Top bar')
  .add('Logo: picture logo 1', () => (
    withProps(Logo, {
      href: 'http://example.com',
      text: 'Bikerrrs',
      image: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
    })))
  .add('Logo: picture logo 2', () => (
    withProps(Logo, {
      href: 'http://example.com',
      text: 'Aalto Marketplace',
      image: 'https://sharetribe.s3.amazonaws.com/images/communities/wide_logos/501/header_highres/aalto_logo.png?1415956670',
    })))
  .add('Logo: big picture in a container', () => (
    r.div({ style: { height: '80px' } }, r(Logo, {
      href: 'http://example.com',
      text: 'A logo',
      image: 'http://placeimg.com/500/300/any',
    }))))
  .add('Logo: short text logo', () => (
    withProps(Logo, {
      href: 'http://example.com',
      text: 'MRKTPLS',
    })))
  .add('Logo: long text logo', () => (
    withProps(Logo, {
      href: 'http://example.com',
      text: 'MaRKeTPLaSeeeeeeeeeeeeeee!',
    })));
