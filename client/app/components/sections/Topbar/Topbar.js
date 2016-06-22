import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';

import { t } from '../../../utils/i18n';
import { railsContext } from '../../../utils/PropTypes';
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

const LABEL_TYPE_MENU = 'menu';
const LABEL_TYPE_DROPDOWN = 'dropdown';

class Topbar extends Component {
  render() {
    const menuProps = this.props.menu ?
      Object.assign({}, this.props.menu, {
        key: 'menu',
        name: t('web.topbar.menu'),
        identifier: 'Menu',
        menuLabelType: LABEL_TYPE_MENU,
        content: this.props.menu.links.map((l) => (
          {
            active: l.link === this.props.railsContext.location,
            activeColor: this.props.railsContext.marketplace_color1,
            content: l.title,
            href: l.link,
            type: 'menuitem',
          }
        )),
      }) :
      {};

    const available_locales = this.props.locales ? this.props.locales.available_locales : null;
    const hasMultipleLanguages = available_locales && available_locales.length > 1;
    const languageMenuProps = hasMultipleLanguages ?
      Object.assign({}, {
        key: 'languageMenu',
        name: this.props.locales.current_locale,
        identifier: 'LanguageMenu',
        menuLabelType: LABEL_TYPE_DROPDOWN,
        extraClasses: css.topbarLanguageMenuLabel,
        content: this.props.locales.available_locales.map((v) => (
          {
            active: v.locale_ident === this.props.locales.current_locale_ident,
            activeColor: this.props.railsContext.marketplace_color1,
            content: v.locale_name,
            href: v.change_locale_uri,
            type: 'menuitem',
          }
        )),
      }) :
      {};

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
      this.props.menu ? r(Menu, menuProps) : null,
      hasMultipleLanguages ? r(Menu, languageMenuProps) : null,
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
  menu: PropTypes.shape({
    links: PropTypes.arrayOf(PropTypes.shape({
      title: PropTypes.string.isRequired,
      link: PropTypes.string.isRequired,
    })),
  }),
  locales: PropTypes.shape({
    current_locale: PropTypes.string.isRequired,
    current_locale_ident: PropTypes.string.isRequired,
    available_locales: PropTypes.arrayOf(PropTypes.shape({
      locale_name: PropTypes.string.isRequired,
      locale_ident: PropTypes.string.isRequired,
      change_locale_uri: PropTypes.string.isRequired,
    })),
  }),
  railsContext,
};

export default Topbar;
