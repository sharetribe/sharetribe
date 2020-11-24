import { Component, PropTypes } from 'react';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';
import r, { div, p } from 'r-dom';
import classNames from 'classnames';
import Immutable from 'immutable';

import closeIcon from './images/closeIcon.svg';
import css from './FlashNotification.css';

const FLASH_INITIAL_WAIT = 1000;
const FLASH_CLEAR_TIMEOUT = 15000;
const TRANSITION_TIMEOUT = 350;

const Message = function Message({ message, closeHandler, noticeRef }) {

  const errorClass = message.type === 'error' ? css.error : null;
  return div({
    className: classNames('FlashNotification_message', css.message, errorClass),
    ref: noticeRef,
    'data-id': message.id,
  }, [
    p({
      className: css.messageContent,
      dangerouslySetInnerHTML: {
        __html: message.content,
      },
    }),
    div({
      className: css.closeIcon,
      onClick: closeHandler,
      dangerouslySetInnerHTML: {
        __html: closeIcon,
      },
    }),
  ]);
};

const delayedPromiseCurry = (timeoutRefs) => (timeMs, name) => (
  new Promise((resolve) => (
    timeoutRefs.push({ name, timeout: setTimeout(resolve, timeMs) })
  ))
);

const clearTimeouts = (timeouts, name = null) => {
  timeouts.forEach((t) => {
    if (name == null || t.name === name) {
      window.clearTimeout(t.timeout);
    }
  });
};

class FlashNotification extends Component {

  constructor(props, context) {
    super(props, context);

    this.state = {
      isMounted: false,
      isHovering: false,
    };

    this.messageRefs = new Immutable.Map();
    this.timeouts = [];
    this.delay = delayedPromiseCurry(this.timeouts);

    this.handleClose = this.handleClose.bind(this);
    this.handleMouseOver = this.handleMouseOver.bind(this);
    this.handleMouseOut = this.handleMouseOut.bind(this);
    this.clearNotices = this.clearNotices.bind(this);
  }

  componentDidMount() {
    this.setState({ isMounted: true }); // eslint-disable-line react/no-set-state
  }

  componentWillUnmount() {
    this.setState({ isMounted: false }); // eslint-disable-line react/no-set-state
    this.timeouts.forEach((t) => window.clearTimeout(t.timeout));
  }

  clearNotices(timeout) {
    const that = this;
    return that.delay(timeout, 'Clear notifications')
      .then(() => {
        if (that.state.isHovering) {
          clearTimeouts(that.timeouts, 'Clear notifications');
        } else {
          that.props.messages
            .filterNot((msg) => msg.type === 'error')
            .forEach((msg) => that.props.actions.removeFlashNotification(msg.id));
        }
      });
  }

  handleClose(event) {
    this.messageRefs.forEach((messageRef) => {
      if (messageRef && messageRef.contains(event.currentTarget)) {
        const that = this;
        const id = messageRef.dataset.id;

        // Mark message as read
        that.props.actions.removeFlashNotification(id);
      }
    });
  }

  handleMouseOver() {
    this.setState({ isHovering: true }); // eslint-disable-line react/no-set-state
  }

  handleMouseOut() {
    this.setState({ isHovering: false }); // eslint-disable-line react/no-set-state
  }

  render() {
    if (this.state.isMounted) {
      const that = this;

      // Show Flash notifications after a short timeout.
      // Animations are more effective when page doesn't have too many loading images
      // Clear unimportant messages after a 15s break;
      this.delay(FLASH_INITIAL_WAIT, 'Add notifications')
        .then(() => that.clearNotices(FLASH_CLEAR_TIMEOUT));
    }

    return r(ReactCSSTransitionGroup,
      {
        className: classNames('FlashNotification', css.notifications, css.cssTransitionGroup),
        component: 'div',
        onMouseOver: this.handleMouseOver,
        onMouseOut: this.handleMouseOut,
        transitionName: {
          enter: css.enterRight,
          enterActive: css.enterRightActive,
          leave: css.leaveRight,
          leaveActive: css.leaveRightActive,
        },
        transitionEnterTimeout: TRANSITION_TIMEOUT,
        transitionLeaveTimeout: TRANSITION_TIMEOUT,
      },
      this.state.isMounted && this.props.messages.size > 0 ?
        this.props.messages.map((msg) => (
          msg.isRead ?
            null :
            r(Message, {
              key: msg.content,
              message: msg,
              closeHandler: this.handleClose,
              noticeRef: (c) => {
                this.messageRefs = this.messageRefs.set(msg.id, c);
              },
            })
        )).toArray() :
        null
      );
  }
}

const { func, instanceOf, shape } = PropTypes;
FlashNotification.propTypes = {
  actions: shape({
    removeFlashNotification: func.isRequired,
  }).isRequired,
  messages: instanceOf(Immutable.List).isRequired,
};

export default FlashNotification;
