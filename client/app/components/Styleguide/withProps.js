import r, { div, strong, pre } from 'r-dom';
import { Component } from 'react';
import css from './ColorsAndTypography.css';

const defaultRailsContext = {
  host: 'test.lvh.me',
  href: 'http://test.lvh.me:3000/',
  httpAcceptLanguage: 'en-US,en;q=0.8,fi;q=0.6',
  i18nDefaultLocale: 'en',
  i18nLocale: 'en',
  location: '/',
  marketplaceId: 1,
  marketplace_color1: '#ee4',
  marketplace_color2: '#00a26c',
  pathname: '/',
  port: 3000,
  scheme: 'http',
  search: null,
  serverSide: false,
};

const withProps = function withProps(component, props) {
  return div([
    r(component, props),
    r.strong({ style: { marginTop: '2em', display: 'block' } }, 'Props:'),
    r.pre({
      style: {
        marginTop: '1em',
        background: 'lightGrey',
        padding: '1em',
        display: 'inline-block',
      } },
      JSON.stringify(props, null, '  ')),
  ]);
};

const storify = (ComposedComponent, containerStyle) => (
  class EnhancedComponent extends Component {
    render() {
      return div(null, [
        div({ className: css.componentWrapper, key: 'componentWrapper' }, [
          div(containerStyle, ComposedComponent),
        ]),

        strong({ className: css.propsTitle, key: 'proprsTitle' }, 'Props:'),
        pre({
          className: css.propsWrapper,
          key: 'propsWrapper',
        },
        JSON.stringify({ props: ComposedComponent.props }, null, '  ')),
      ]);
    }
  }
);

export default withProps;
export { storify, defaultRailsContext };
