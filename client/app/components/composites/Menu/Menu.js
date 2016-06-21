import { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';
import r, { div } from 'r-dom';

import MenuLabel from './MenuLabel';
import MenuLabelDropdown from './MenuLabelDropdown';
import MenuContent from './MenuContent';
import css from './Menu.css';

const INITIAL_ARROW_POSITION = 25;
const MENULABEL_MAP = {
  menu: MenuLabel,
  dropdown: MenuLabelDropdown,
};

const isTouch = !!(typeof window !== 'undefined' && (('ontouchstart' in window) || window.navigator.msMaxTouchPoints > 0));

class Menu extends Component {

  constructor(props, context) {
    super(props, context);

    this.handleClick = this.handleClick.bind(this);
    this.handleBlur = this.handleBlur.bind(this);
    this.calculateDropdownPosition = this.calculateDropdownPosition.bind(this);
    this.state = {
      isOpen: false,
      arrowPosition: INITIAL_ARROW_POSITION,
    };
  }

  componentDidMount() {
    this.calculateDropdownPosition();
  }

  calculateDropdownPosition() {
    const menuLabel = ReactDOM.findDOMNode(this.menuLabel);

    this.setState({ // eslint-disable-line react/no-did-mount-set-state, react/no-set-state
      arrowPosition: menuLabel.offsetWidth > (INITIAL_ARROW_POSITION * 2) ? menuLabel.offsetWidth / 2 : INITIAL_ARROW_POSITION, // eslint-disable-line no-magic-numbers
    });
  }

  handleClick() {
    if (isTouch) {
      this.setState({ isOpen: !this.state.isOpen });// eslint-disable-line react/no-set-state
    }
  }

  handleBlur() {
    this.setState({ isOpen: false });// eslint-disable-line react/no-set-state
  }

  render() {
    const requestedLabel = MENULABEL_MAP[this.props.menuLabelType];
    const LabelComponent = requestedLabel != null ? requestedLabel : null;
    const touchClass = isTouch ? '' : css.touchless;
    const openClass = this.state.isOpen ? css.openMenu : '';
    const extraClasses = this.props.extraClasses ? this.props.extraClasses : '';

    return div({
      className: `Menu ${css.menu} ${extraClasses} ${touchClass} ${openClass}`,
      onClick: this.handleClick,
      onBlur: this.handleBlur,
      tabIndex: 0,
    }, [
      r(LabelComponent,
        {
          key: `${this.props.identifier}_menulabel`,
          name: this.props.name,
          extraClasses: this.props.extraClassesLabel,
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
  extraClassesLabel: PropTypes.string,
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
