import { Component, PropTypes } from 'react';
import { div, span } from 'r-dom';
import css from './Menu.css';
import moreIcon from './images/moreIcon.svg';

class MenuLabelMore extends Component {
  render() {
    const extraClasses = this.props.extraClasses ? this.props.extraClasses : '';
    return (
      div({
        className: `MenuLabel ${css.menuLabel} ${extraClasses}`,
      }, [
        span({
          className: css.menuLabelIcon,
          dangerouslySetInnerHTML: {
            __html: moreIcon,
          },
        }),
        this.props.name,
      ])
    );
  }
}

MenuLabelMore.propTypes = {
  name: PropTypes.string.isRequired,
  extraClasses: PropTypes.string,
};

export default MenuLabelMore;
