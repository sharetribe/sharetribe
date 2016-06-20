import { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';
import r, { div } from 'r-dom';
import _ from 'lodash';

import MenuLabel from './MenuLabel';
import MenuLabelDropdown from './MenuLabelDropdown';
import MenuContent from './MenuContent';
import css from './Menu.css';

const INITIAL_ARROW_POSITION = 50;
const MENULABEL_MAP = {
  menu: MenuLabel,
  dropdown: MenuLabelDropdown,
};

class Menu extends Component {

  constructor(props, context) {
    super(props, context);

    this.calculateDropdownPosition = this.calculateDropdownPosition.bind(this);
    this.state = {
      arrowPosition: INITIAL_ARROW_POSITION,
    };
  }

  componentDidMount() {
    this.calculateDropdownPosition();
  }

  calculateDropdownPosition() {
    const menuLabel = ReactDOM.findDOMNode(this.menuLabel);

    this.setState({ // eslint-disable-line react/no-did-mount-set-state, react/no-set-state
      arrowPosition: menuLabel.offsetWidth / 2, // eslint-disable-line no-magic-numbers
    });
  }

  render() {
    const requestedLabel = MENULABEL_MAP[this.props.menuLabelType];
    const LabelComponent = requestedLabel != null ? requestedLabel : null;

    return div({
      className: `menu ${css.menu}`,
      onBlur: this.handleBlur,
      onMouseOver: this.handleMouseOver,
      tabIndex: '0',
    }, [
      r(LabelComponent,
        {
          key: `${this.props.identifier}_menulabel`,
          name: this.props.name,
          extraClasses: this.props.extraClasses,
          ref: (c) => {
            this.menuLabel = c;
          },
        }
      ),
      r(MenuContent,
        {
          key: `${this.props.identifier}_menucontent`,
          content: this.props.content,
          arrowPosition: this.state.arrowPosition,
          ref: (c) => {
            this.menuContent = c;
          },
        }
      ),
    ]);
  }
}

Menu.propTypes = {
  name: PropTypes.string.isRequired,
  extraClasses: PropTypes.string,
  identifier: PropTypes.string.isRequired,
  menuLabelType: PropTypes.string,
  content: PropTypes.arrayOf(
    PropTypes.shape({
      active: PropTypes.bool.isRequired,
      activeColor: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired,
      href: PropTypes.string.isRequired,
      type: PropTypes.string.isRequired,
    })
  ).isRequired,
};

export default Menu;
