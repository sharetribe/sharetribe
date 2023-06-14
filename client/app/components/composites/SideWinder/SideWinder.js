/* SideWinder - A generic overlay menu that pushes the page to the side

Usage:

  r(SideWinder, {
    wrapper: document.querySelector('#root'),
    maxWidth: 300,
    minWidth: 200,
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
import ReactTransitionGroup from 'react-addons-transition-group';
import r, { div, button } from 'r-dom';
import classNames from 'classnames';
import Portal from '../Portal/Portal';
import SideWinderTransition from './SideWinderTransition';
import * as cssVariables from '../../../assets/styles/variables';
import { canUseDOM } from '../../../utils/featureDetection';

import css from './SideWinder.css';
import closeIcon from './images/close.svg';

const KEYCODE_ESC = 27;
const ORIENTATION_TIMEOUT = 400;
const SCROLL_TIMEOUT = cssVariables['--SideWinder_animationDurationMs'] + 50; // eslint-disable-line no-magic-numbers

const currentScrollOffset = () => {
  if (!window || !document) {
    // Likely no DOM, e.g. when rendering on the server
    return 0;
  }
  return window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
};

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

const calculateWidth = ({ max, min }) =>
  Math.max((canUseDOM ? Math.min(window.innerWidth, max) : max), min);

class SideWinder extends Component {
  constructor(props) {
    super(props);
    this.onWindowKeyUp = this.onWindowKeyUp.bind(this);
    this.onWindowResize = this.onWindowResize.bind(this);
    this.scrollOffset = null;
  }
  componentDidMount() {
    if (this.props.wrapper.classList.contains(css.wrapper)) {
      throw new Error('Only one SideWinder allowed for a wrapper element at a time.');
    }
    this.props.wrapper.classList.add(css.wrapper);

    window.addEventListener('keyup', this.onWindowKeyUp);
    window.addEventListener('resize', this.onWindowResize);
    window.addEventListener('orientationchange', this.onOrientationChange);

    this.componentDidUpdate();
  }
  componentDidUpdate() {
    if (this.props.isOpen && !this.stopWidthSync) {
      this.stopWidthSync = syncWindowWidthTo(this.props.wrapper);
    } else if (!this.props.isOpen && this.stopWidthSync) {
      this.stopWidthSync();
      this.stopWidthSync = null;
    }
  }
  componentWillUnmount() {
    this.props.wrapper.classList.remove(css.wrapper);
    this.props.wrapper.style.removeProperty('right');
    window.removeEventListener('keyup', this.onWindowKeyUp);
    window.removeEventListener('resize', this.onWindowResize);
    window.removeEventListener('orientationchange', this.onOrientationChange);
    window.clearTimeout(this.orientationTimeout);
    window.clearTimeout(this.scrollTimeout);
  }
  onWindowKeyUp(e) {
    if (this.props.isOpen && e.keyCode === KEYCODE_ESC) {
      this.props.onClose();
    }
  }
  onWindowResize() {
    if (this.props.isOpen) {
      this.render();
    }
  }

  onOrientationChange() {
    this.orientationTimeout = window.setTimeout(() => {
      window.scrollTo(0, document.querySelector(`.${css.orientationHook}`).offsetTop);
    }, ORIENTATION_TIMEOUT);
  }

  render() {
    const isOpen = this.props.isOpen;

    const height = this.props.height ? { height: this.props.height } : {};
    const width = calculateWidth({
      max: this.props.maxWidth,
      min: this.props.minWidth,
    });

    if (isOpen) {
      this.props.wrapper.style.right = `${width}px`;
      this.scrollOffset = currentScrollOffset();
    } else {
      this.props.wrapper.style.removeProperty('right');
      if (this.scrollOffset !== null) {
        this.scrollTimeout = window.setTimeout(() => {
          window.scrollTo(0, this.scrollOffset);
        }, SCROLL_TIMEOUT);
      }
    }

    return r(Portal, {
      parentElement: this.props.wrapper,
    }, [
      r(ReactTransitionGroup, [
        div({
          className: classNames(css.orientationHook, css.overlay),
          style: {
            top: 0,
          },
          onClick: this.props.onClose,
          onTouchMove: (e) => {
            e.preventDefault();
          },
        }),
        isOpen ?
          r(SideWinderTransition, {
            enterTimeout: cssVariables['--SideWinder_animationDurationMs'],
            leaveTimeout: cssVariables['--SideWinder_animationDurationMs'],
          }, [
            div({
              className: css.root,
              style: {
                ...height,
                width,
                right: -1 * width,
                top: 0,
              },
            }, [
              this.props.children,
              button({
                onClick: this.props.onClose,
                className: css.closeButton,
                dangerouslySetInnerHTML: { __html: closeIcon },
                id: 'side-winder-close-button',
              }),
            ]),
          ]) :
        null,
      ]),
    ]);
  }
}

SideWinder.propTypes = {
  wrapper: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  height: PropTypes.number,
  maxWidth: PropTypes.number.isRequired,
  minWidth: PropTypes.number.isRequired,
  isOpen: PropTypes.bool.isRequired,
  onClose: PropTypes.func.isRequired,
  children: PropTypes.any, // eslint-disable-line react/forbid-prop-types
};

export default SideWinder;
