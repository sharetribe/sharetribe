import { Component, PropTypes } from 'react';
import { div, a, span } from 'r-dom';

import css from './MenuItem.css';
import variables from '../../../assets/styles/variables';

class MenuItem extends Component {

  constructor(props, context) {
    super(props, context);
    this.activeColor = this.props.activeColor || variables['--customColorFallback'];
    this.textColor = this.props.active ? variables['--MenuItem_textColorSelected'] : this.props.textColor || variables['--MenuItem_textColorDefault'];
  }

  render() {
    const extraClasses = this.props.extraClasses ? this.props.extraClasses : '';
    const extraClassesLink = this.props.extraClassesLink ? this.props.extraClassesLink : '';
    const inlineStyling = this.props.textColor != null ? { style: { color: this.textColor } } : {};
    const linkProps = Object.assign({
      className: `MenuItem_link ${css.menuitemLink} ${extraClassesLink}`,
      href: this.props.href,
    }, inlineStyling);

    return div({ className: `MenuItem ${css.menuitem}  ${extraClasses}` }, [
      this.props.active ?
        span({
          className: css.activeIndicator,
          style: { backgroundColor: this.activeColor },
        }) :
        null,
      a(
        linkProps,
        this.props.content),
    ]);
  }
}

const { bool, number, string } = PropTypes;

MenuItem.propTypes = {
  active: bool.isRequired,
  activeColor: string.isRequired,
  content: string.isRequired,
  extraClasses: string,
  extraClassesLink: string,
  href: string.isRequired,
  index: number.isRequired,
  textColor: string,
  type: string.isRequired,
};

export default MenuItem;
