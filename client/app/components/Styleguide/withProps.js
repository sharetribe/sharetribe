import r, { div, strong, pre } from 'r-dom';
import { Component } from 'react';
import css from './ColorsAndTypography.css';

const defaultRailsContext = {
  i18nLocale: 'en',
  i18nDefaultLocale: 'en',
  location: '/',
  pathname: '/',
  marketplaceId: 1,

  marketplace_color1: '#64A',

  loggedInUsername: 'foo',
};

const withProps = function withProps(component, props, children) {
  return div([
    r(component, props, children),
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
        div({ key: 'componentWrapper' }, [
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
