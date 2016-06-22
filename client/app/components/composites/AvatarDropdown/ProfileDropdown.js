import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';
import classNames from 'classnames';

import css from './ProfileDropdown.css';
import inboxEmptyIcon from './images/inboxEmptyIcon.svg';
import profileIcon from './images/profileIcon.svg';
import settingsIcon from './images/settingsIcon.svg';
import { className } from '../../../utils/PropTypes';

class ProfileActionCard extends Component {
  render() {
    return div({ className: css.profileAction, onClick: this.props.action }, [
      div({ className: css.profileActionIcon, dangerouslySetInnerHTML: { __html: this.props.icon } }),
      div({ className: css.profileActionLabel }, this.props.label),
    ]);
  }
}

ProfileActionCard.propTypes = {
  icon: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  action: PropTypes.func.isRequired,
};

class ProfileDropdown extends Component {
  render() {
    return div({
      className: classNames(css.profileDropdown, this.props.className),
    }, [
      div({ className: css.rootArrow }),
      div({ className: css.box }, [
        div({ className: css.profileActions }, [
          r(ProfileActionCard, { label: 'Inbox', icon: inboxEmptyIcon, action: this.props.actions.inboxAction }),
          r(ProfileActionCard, { label: 'Profile', icon: profileIcon, action: this.props.actions.profileAction }),
          r(ProfileActionCard, { label: 'Settings', icon: settingsIcon, action: this.props.actions.settingsAction }),
        ]),
        div({ className: css.logoutArea }, [
          div({
            className: css.adminLink,
            style: { color: this.props.customColor },
            onClick: this.props.actions.adminDashboardAction,
          }, 'Admin dashboard'),
          div({
            className: css.logoutLink,
            onClick: this.props.actions.logoutAction,
          }, 'Logout'),
        ]),
      ]),
    ]);
  }
}

ProfileDropdown.propTypes = {
  actions: PropTypes.shape({
    inboxAction: PropTypes.func.isRequired,
    profileAction: PropTypes.func.isRequired,
    settingsAction: PropTypes.func.isRequired,
    adminDashboardAction: PropTypes.func.isRequired,
    logoutAction: PropTypes.func.isRequired,
  }).isRequired,
  customColor: PropTypes.string.isRequired,
  className,
};

export default ProfileDropdown;
