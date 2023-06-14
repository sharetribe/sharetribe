import { Component, PropTypes } from 'react';
import { div, span } from 'r-dom';
import css from './MenuMobile.css';
import hamburgerIcon from './images/hamburgerIcon.svg';

class MenuLabelMobile extends Component {

  render() {
    const extraClasses = this.props.extraClasses ? this.props.extraClasses : '';
    return (
      div({
        className: `MenuLabelMobile ${css.menuLabelMobile} ${extraClasses}`,
        onClick: this.props.handleClick,
      }, [
        span({
          className: css.menuLabelMobileIcon,
          title: this.props.name,
          dangerouslySetInnerHTML: {
            __html: hamburgerIcon,
          },
        }),
      ].concat(this.props.children))
    );
  }
}

MenuLabelMobile.propTypes = {
  name: PropTypes.string.isRequired,
  handleClick: PropTypes.func.isRequired,
  extraClasses: PropTypes.string,
  children: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node,
  ]),
};

export default MenuLabelMobile;
