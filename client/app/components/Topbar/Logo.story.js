import { storiesOf } from '@kadira/storybook';
import withProps from '../Styleguide/withProps';
import r from 'r-dom';

import Logo from './Logo';

storiesOf('Header logo')
  .add('Picture logo 1', () =>(
    withProps(Logo, {
      href: 'http://example.com',
      image: 'https://sharetribe.s3.amazonaws.com/images/communities/wide_logos/1194/header_highres/The_Quiver_desktop.png?1414049649'
    })))
  .add('Picture logo 2', () =>(
    withProps(Logo, {
      href: 'http://example.com',
      image: 'https://sharetribe.s3.amazonaws.com/images/communities/wide_logos/501/header_highres/aalto_logo.png?1415956670'
    })))
  .add('Big picture in a container', () =>(
    r.div({ style: { height: '80px' } }, r(Logo, {
      href: 'http://example.com',
      image: 'http://placeimg.com/500/300/any'
    }))))
  .add('Short text logo', () =>(
    withProps(Logo, {
      href: 'http://example.com',
      text: 'MRKTPLS'
    })))
  .add('Long text logo', () =>(
    withProps(Logo, {
      href: 'http://example.com',
      text: 'MaRKeTPLaSeeeeeeeeeeeeeee!'
    })))
