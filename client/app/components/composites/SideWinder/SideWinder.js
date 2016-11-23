/* SideWinder - A generic overlay menu that pushes the page to the side

Usage:

  r(SideWinder, {
    wrapper: document.querySelector('#root'),
    width: 300,
    isOpen: false,
    onClose: handleClose,
  }, [
    p('This will be within the side menu'),
  ]);

This will render the side menu outside the current React render tree
and within the given wrapper element. This is to enable adding the
component to a page with other UI components that might not be from
the same React app (or React at all) that need to be pushed to the
side for the menu to open.

Controlling the menu open/close animation is done by changing the
`isOpen` flag.

This is quite a dirty component that breaks away from the React world,
but tries to contain all the hackiness within itself.

*/
import { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';
import r, { div, button } from 'r-dom';

import css from './SideWinder.css';
import closeIcon from './images/close.svg';

const KEYCODE_ESC = 27;

// Starts syncing the window width to the given element. Returns a
// function that stops the listening.
//
// This can be used to keep the normal responsiveness of the given
// element intact regardless of rendering it outside the normal window
// area, e.g. pushed to the side.
const syncWindowWidthTo = (el) => {
  /* eslint-disable no-param-reassign */

  const originalWidth = el.style.width;
  const update = () => {
    el.style.width = `${window.innerWidth}px`;
  };
  update();
  window.addEventListener('resize', update);

  return () => {
    window.removeEventListener('resize', update);
    el.style.width = originalWidth;
  };

  /* eslint-enable no-param-reassign */
};

const SideWinderContent = (props) => div(
  { className: css.content },
  [
    button({
      onClick: props.onClose,
      className: css.closeButton,
      dangerouslySetInnerHTML: { __html: closeIcon },
    }),
    props.children,
  ]
);

SideWinderContent.propTypes = {
  onClose: PropTypes.func.isRequired,
};

class SideWinder extends Component {
  constructor(props, context) {
    super(props, context);
    this.update = this.update.bind(this);
    this.onWindowKeyUp = this.onWindowKeyUp.bind(this);
    this.onBodyTouchMove = this.onBodyTouchMove.bind(this);
  }
  componentDidMount() {
    this.props.wrapper.classList.add(css.wrapper);

    // Two DOM elements are created: el and overlay, where el will be
    // the root node for the whole side menu and overlay will hide the
    // wrapper element contents. Both elements are manually rendered
    // to the wrapper element, and React handles the tree within the
    // el element.

    this.rootEl = document.createElement('div');
    this.rootEl.style.width = `${this.props.width}px`;
    this.rootEl.style.right = `-${this.props.width}px`;
    this.rootEl.className = css.root;

    this.overlayEl = document.createElement('div');
    this.overlayEl.className = css.overlay;
    this.overlayEl.addEventListener('click', this.props.onClose);

    this.props.wrapper.appendChild(this.rootEl);
    this.props.wrapper.appendChild(this.overlayEl);

    window.addEventListener('keyup', this.onWindowKeyUp);
    window.addEventListener('resize', this.update);

    // Prevent bg scrolling on touch devices.
    document.body.addEventListener('touchmove', this.onBodyTouchMove);

    this.update();
  }
  componentDidUpdate() {
    this.update();
  }
  componentWillUnmount() {
    ReactDOM.unmountComponentAtNode(this.rootEl);

    const wrapper = this.props.wrapper;
    wrapper.removeChild(this.rootEl);
    wrapper.removeChild(this.overlayEl);
    wrapper.classList.remove(css.wrapper);

    // There needs to be a class to target the body element e.g. to
    // prevent bg scrolling.
    document.body.classList.remove(css.winderOpen);

    window.removeEventListener('keyup', this.onWindowKeyUp);
    window.removeEventListener('resize', this.update);
    document.body.removeEventListener('touchmove', this.onBodyTouchMove);

    if (this.stopWidthSync) {
      this.stopWidthSync();
      this.stopWidthSync = null;
    }
  }
  onBodyTouchMove(e) {
    if (this.props.isOpen) {
      e.preventDefault();
    }
  }
  onWindowKeyUp(e) {
    if (this.props.isOpen && e.keyCode === KEYCODE_ESC) {
      this.props.onClose();
    }
  }
  update() {
    const isOpen = this.props.isOpen;
    const scrollOffset = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
    const height = window.innerHeight;

    if (isOpen) {
      document.body.classList.add(css.winderOpen);
      this.rootEl.style.top = `${scrollOffset}px`;
      this.overlayEl.style.top = `${scrollOffset}px`;
      this.rootEl.style.height = `${height}px`;
      this.overlayEl.style.height = `${height}px`;
      this.props.wrapper.style.right = `${this.props.width}px`;
    } else {
      document.body.classList.remove(css.winderOpen);
      this.rootEl.style.removeProperty('top');
      this.rootEl.style.removeProperty('height');
      this.overlayEl.style.removeProperty('top');
      this.overlayEl.style.removeProperty('height');
      this.props.wrapper.style.removeProperty('right');
    }

    if (isOpen && !this.stopWidthSync) {
      this.stopWidthSync = syncWindowWidthTo(this.props.wrapper);
    } else if (!isOpen && this.stopWidthSync) {
      this.stopWidthSync();
      this.stopWidthSync = null;
    }

    ReactDOM.render(r(SideWinderContent, {
      onClose: this.props.onClose,
    }, this.props.children), this.rootEl);
  }

  render() {
    // The component is rendered manually within the given wrapper
    // element which is outside the current render tree and might have
    // other non-React DOM elements that should not be touched.
    return null;
  }
}

SideWinder.propTypes = {
  wrapper: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  width: PropTypes.number.isRequired,
  isOpen: PropTypes.bool.isRequired,
  onClose: PropTypes.func.isRequired,
  children: PropTypes.object, // eslint-disable-line react/forbid-prop-types
};

export default SideWinder;
