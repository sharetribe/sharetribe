/* eslint-disable react/no-set-state  */

import { Component, PropTypes } from 'react';
import { div } from 'r-dom';

import css from './SideWinder.css';

// ReactTransitionGroup is a low level animation API that handles
// component mounting, unmounting and leaving/entering between
// animation states. It works by calling certain lifecycle methods on
// its child component that can then asynchronously handle the
// transitions to other states.
//
// This component implements the required lifecycle methods to add
// state classes to its container, allowing for CSS styles to attach
// to transitions properly.
//
// The component also attaches state classes to document.body for
// styling other components outside the current render tree position.
//
// See: https://facebook.github.io/react/docs/animation.html#reacttransitiongroup
class SideWinderTransition extends Component {
  constructor(props) {
    super(props);
    this.state = {
      open: true,
      entering: false,
      leaving: false,
    };
  }
  componentWillUnmount() {
    document.body.classList.remove(css.transitionVisible);
    document.body.classList.remove(css.transitionEntering);
    document.body.classList.remove(css.transitionLeaving);
    document.body.classList.remove(css.transitionOpen);
    window.clearTimeout(this.enterTimeoutId);
    window.clearTimeout(this.leaveTimeoutId);
  }
  componentWillAppear(callback) {
    callback();
  }
  componentWillEnter(callback) {
    this.setState({ entering: true, open: true });
    this.enterTimeoutId = window.setTimeout(callback, this.props.enterTimeout);
  }
  componentDidEnter() {
    this.setState({ entering: false });
  }
  componentWillLeave(callback) {
    this.setState({ leaving: true, open: false });
    this.leaveTimeoutId = window.setTimeout(callback, this.props.leaveTimeout);
  }
  componentDidLeave() {
    this.setState({ leaving: false });
  }
  render() {
    document.body.classList.add(css.transitionVisible);

    if (this.state.entering) {
      document.body.classList.add(css.transitionEntering);
    } else {
      document.body.classList.remove(css.transitionEntering);
    }

    if (this.state.leaving) {
      document.body.classList.add(css.transitionLeaving);
    } else {
      document.body.classList.remove(css.transitionLeaving);
    }

    if (this.state.open) {
      document.body.classList.add(css.transitionOpen);
    } else {
      document.body.classList.remove(css.transitionOpen);
    }

    return div({ className: css.transition }, this.props.children);
  }
}

SideWinderTransition.propTypes = {
  enterTimeout: PropTypes.number.isRequired,
  leaveTimeout: PropTypes.number.isRequired,
  children: PropTypes.any, // eslint-disable-line react/forbid-prop-types
};

export default SideWinderTransition;
