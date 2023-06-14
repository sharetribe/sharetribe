import { Component, PropTypes } from 'react';
import { div, span } from 'r-dom';
import css from './Menu.css';
import hamburgerIcon from './images/hamburgerIcon.svg';

class MenuLabel extends Component {

  render() {
    const extraClasses = this.props.extraClasses ? this.props.extraClasses : '';
    return (
      div({
        className: `MenuLabel ${css.menuLabel} ${extraClasses}`,
        ref: this.props.menuLabelRef,
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
  extraClasses: PropTypes.string,
  name: PropTypes.string.isRequired,
  menuLabelRef: PropTypes.func.isRequired,
};

export default MenuLabel;
