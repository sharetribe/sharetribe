import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';
import classNames from 'classnames';

import { className } from '../../../utils/PropTypes';

import MenuLabel from './MenuLabel';
import MenuLabelDropdown from './MenuLabelDropdown';
import MenuContent from './MenuContent';
import css from './Menu.css';

const INITIAL_ARROW_POSITION = 25;
const HOVER_TIMEOUT = 250;
const MENULABEL_MAP = {
  menu: MenuLabel,
  dropdown: MenuLabelDropdown,
};

class Menu extends Component {

  constructor(props, context) {
    super(props, context);

    this.handleMouseover = this.handleMouseover.bind(this);
    this.handleMouseout = this.handleMouseout.bind(this);
    this.handleClick = this.handleClick.bind(this);
    this.handleBlur = this.handleBlur.bind(this);
    this.calculateDropdownPosition = this.calculateDropdownPosition.bind(this);
    this.state = {
      isOpen: false,
      isMounted: false,
      arrowPosition: INITIAL_ARROW_POSITION,
    };
    this.mouseOverTimout = null;
    this.mouseOutTimout = null;
  }

  componentDidMount() {
    this.calculateDropdownPosition();
    this.setState({ isMounted: true }); // eslint-disable-line react/no-set-state
  }

  calculateDropdownPosition() {
    this.setState({ // eslint-disable-line react/no-did-mount-set-state, react/no-set-state
      arrowPosition: this.menuLabel.offsetWidth > (INITIAL_ARROW_POSITION * 2) ? Math.floor(this.menuLabel.offsetWidth / 2) : INITIAL_ARROW_POSITION, // eslint-disable-line no-magic-numbers
    });
  }

  handleMouseover() {
    window.clearTimeout(this.mouseOutTimout);
    window.clearTimeout(this.mouseOverTimout);
    this.mouseOverTimout = setTimeout(() => (
      this.setState({ isOpen: true })  // eslint-disable-line react/no-set-state
      ), HOVER_TIMEOUT);
  }

  handleMouseout() {
    window.clearTimeout(this.mouseOverTimout);
    this.mouseOutTimout = setTimeout(() => (
      this.setState({ isOpen: false }) // eslint-disable-line react/no-set-state
      ), HOVER_TIMEOUT);
  }

  handleClick() {
    this.setState({ isOpen: !this.state.isOpen }); // eslint-disable-line react/no-set-state
  }

  handleBlur(event) {
    // FocusEvent is fired faster than the link elements native click handler
    // gets its own event. Therefore, we need to check the origin of this FocusEvent.
    if (!this.menu.contains(event.relatedTarget)) {
      this.setState({ isOpen: false });// eslint-disable-line react/no-set-state
    }
  }

  render() {
    const requestedLabel = MENULABEL_MAP[this.props.menuLabelType];
    const LabelComponent = requestedLabel != null ? requestedLabel : null;
    const openOnHoverClass = this.state.isMounted ? '' : css.openOnHover;
    const transitionDelayClass = this.state.isMounted ? '' : css.transitionDelay;
    const openClass = this.state.isOpen ? css.openMenu : '';

    return div({
      className: classNames(this.props.className, 'Menu', css.menu, openOnHoverClass, openClass),
      onMouseOver: this.handleMouseover,
      onMouseOut: this.handleMouseout,
      onClick: this.handleClick,
      onBlur: this.handleBlur,
      tabIndex: 0,
      ref: (c) => {
        this.menu = c;
      },
    }, [
      r(LabelComponent,
        {
          key: `${this.props.identifier}_menulabel`,
          name: this.props.name,
          extraClasses: this.props.extraClassesLabel,
          menuLabelRef: (c) => {
            this.menuLabel = c;
          },
        }
      ),
      r(MenuContent,
        {
          className: transitionDelayClass,
          key: `${this.props.identifier}_menucontent`,
          content: this.props.content,
          arrowPosition: this.state.arrowPosition,
        }
      ),
    ]);
  }
}

Menu.propTypes = {
  name: PropTypes.string.isRequired,
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
  className,
};

export default Menu;
