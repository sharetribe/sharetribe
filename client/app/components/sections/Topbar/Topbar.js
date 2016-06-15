import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';

import css from './Topbar.css';

import Logo from '../../elements/Logo/Logo';
import SearchBar from '../../composites/SearchBar/SearchBar';
import Menu from '../../composites/Menu/Menu';
import AvatarDropdown from '../../composites/AvatarDropdown/AvatarDropdown';

const avatarDropdownProps = (avatarDropdown) => {
  // TODO: color from railscontext
  const actions = {
    inboxAction: () => false,
    profileAction: () => false,
    settingsAction: () => false,
    adminDashboardAction: () => false,
    logoutAction: () => false,
  };
  return { actions, ...avatarDropdown };
};

class Topbar extends Component {
  render() {
    return div({ className: css.topbar }, [
      r(Logo, { ...this.props.logo, classSet: css.topbarLogo }),
      this.props.search ?
        r(SearchBar, {
          mode: this.props.search.mode,
          keywordPlaceholder: this.props.search.keyword_placeholder,
          locationPlaceholder: this.props.search.location_placeholder,
          onSubmit: this.props.search.onSubmit,
        }) :
        null,
      this.props.avatarDropdown ?
        r(AvatarDropdown, {
          ...avatarDropdownProps(this.props.avatarDropdown),
          classSet: css.topbarAvatarDropdown,
        }) :
        null,
      this.props.menu ?
        r(Menu, Object.assign({}, this.props.menu, { key: 'menu' })) :
        null,
      this.props.languageMenu ?
        r(Menu, Object.assign({}, this.props.languageMenu, { key: 'languageMenu' })) :
        null,
    ]);
  }
}

Topbar.propTypes = {
  logo: PropTypes.shape(Logo.propTypes).isRequired,
  search: PropTypes.shape({
    mode: PropTypes.string,
    keyword_placeholder: PropTypes.string,
    location_placeholder: PropTypes.string,
    onSubmit: PropTypes.func.isRequired,
  }),
  avatarDropdown: PropTypes.shape(AvatarDropdown.propTypes),
  menu: PropTypes.shape(Menu.propTypes),
  languageMenu: PropTypes.shape(Menu.propTypes),
};

export default Topbar;
