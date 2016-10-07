import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';
import classNames from 'classnames';

import { className } from '../../../utils/PropTypes';
import { hasTouchEvents } from '../../../utils/featureDetection';
import ProfileDropdown from './ProfileDropdown';
import Avatar from '../../elements/Avatar/Avatar';
import NotificationBadge from '../../elements/NotificationBadge/NotificationBadge';

import css from './AvatarDropdown.css';

class AvatarDropdown extends Component {
  constructor(props, context) {
    super(props, context);

    this.handleClick = this.handleClick.bind(this);
    this.handleBlur = this.handleBlur.bind(this);

    this.state = {
      isOpen: false,
    };
  }

  handleClick() {
    if (hasTouchEvents) {
      this.setState({ isOpen: !this.state.isOpen });// eslint-disable-line react/no-set-state
    }
  }

  handleBlur(event) {
    // FocusEvent is fired faster than the link elements native click handler
    // gets its own event. Therefore, we need to check the origin of this FocusEvent.
    if (this.state.isOpen && !this.profileDropdown.contains(event.relatedTarget)) {
      this.setState({ isOpen: false });// eslint-disable-line react/no-set-state
    }
  }

  render() {
    const touchClass = hasTouchEvents ? '' : css.touchless;
    const openClass = this.state.isOpen ? css.openDropdown : '';
    const notificationsClass = this.props.notificationCount > 0 ? css.hasNotifications : null;
    const notificationBadgeInArray = this.props.notificationCount > 0 ?
      [r(NotificationBadge, { className: css.notificationBadge }, this.props.notificationCount)] :
      [];
    return div({
      onClick: this.handleClick,
      onBlur: this.handleBlur,
      tabIndex: 0,
      className: classNames('AvatarDropdown', this.props.className, touchClass, openClass, css.avatarDropdown, notificationsClass),
    }, [
      div({ className: css.avatarWithNotifications }, [
        r(Avatar, this.props.avatar),
      ].concat(notificationBadgeInArray)),
      r(ProfileDropdown, {
        className: css.avatarProfileDropdown,
        customColor: this.props.customColor,
        actions: this.props.actions,
        isAdmin: this.props.isAdmin,
        notificationCount: this.props.notificationCount,
        translations: this.props.translations,
        profileDropdownRef: (c) => {
          this.profileDropdown = c;
        },
      }),
    ]);
  }
}

const { profileDropdownRef, ...passedThroughProps } = ProfileDropdown.propTypes; // eslint-disable-line no-unused-vars
AvatarDropdown.propTypes = {
  avatar: PropTypes.shape(Avatar.propTypes).isRequired,
  notificationCount: PropTypes.number,
  ...passedThroughProps,
  className,
};

export default AvatarDropdown;
