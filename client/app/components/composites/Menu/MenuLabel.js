import { Component, PropTypes } from 'react';
import { div, span } from 'r-dom';
import css from './Menu.css';
import hamburgerIcon from './images/hamburgerIcon.svg';

class MenuLabel extends Component {

  render() {
    const extraClasses = this.props.extraClasses ? this.props.extraClasses : '';
    return (
      div({
        className: `menu__label ${css.menuLabel} ${extraClasses}`,
        tabIndex: '-1',
      }, [
        span({
          className: css.menuLabelIcon,
          dangerouslySetInnerHTML: {
            __html: hamburgerIcon,
          },
        }),
        this.props.name,
      ])
    );
  }
}

MenuLabel.propTypes = {
  name: PropTypes.string.isRequired,
  extraClasses: PropTypes.string,
};

export default MenuLabel;
