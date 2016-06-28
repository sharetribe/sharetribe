import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';

import { t } from '../../../utils/i18n';
import { routes, railsContext } from '../../../utils/PropTypes';
import css from './Topbar.css';
import styleVariables from '../../../assets/styles/variables';

import Logo from '../../elements/Logo/Logo';
import SearchBar from '../../composites/SearchBar/SearchBar';
import Menu from '../../composites/Menu/Menu';
import MenuMobile from '../../composites/MenuMobile/MenuMobile';
import AvatarDropdown from '../../composites/AvatarDropdown/AvatarDropdown';
import AddNewListingButton from '../../elements/AddNewListingButton/AddNewListingButton';

const avatarDropdownProps = (avatarDropdown, customColor) => {
  const color = customColor || styleVariables['--customColorFallback'];
  const actions = {
    inboxAction: () => false,
    profileAction: () => false,
    settingsAction: () => false,
    adminDashboardAction: () => false,
    logoutAction: () => false,
  };
  return { actions, customColor: color, ...avatarDropdown };
};

const LABEL_TYPE_MENU = 'menu';
const LABEL_TYPE_DROPDOWN = 'dropdown';

const SEARCH_ENABLED = false;

const profileLinks = function profileLinks(username, router, marketplaceContext) {
  if (username) {
    return [
      {
        active: router.person_inbox_path(username) === marketplaceContext.location,
        activeColor: marketplaceContext.marketplace_color1,
        content: t('web.topbar.inbox'),
        href: router.person_inbox_path(username),
        type: 'menuitem',
      },
      {
        active: router.person_path(username) === marketplaceContext.location,
        activeColor: marketplaceContext.marketplace_color1,
        content: t('web.topbar.profile'),
        href: router.person_path(username),
        type: 'menuitem',
      },
      {
        active: `${router.person_path(username)}?show_closed=1` === marketplaceContext.location,
        activeColor: marketplaceContext.marketplace_color1,
        content: t('web.topbar.manage_listings'),
        href: `${router.person_path(username)}?show_closed=1`,
        type: 'menuitem',
      },
      {
        active: router.person_settings_path(username) === marketplaceContext.location,
        activeColor: marketplaceContext.marketplace_color1,
        content: t('web.topbar.settings'),
        href: router.person_settings_path(username),
        type: 'menuitem',
      },
      {
        active: router.logout_path() === marketplaceContext.location,
        activeColor: marketplaceContext.marketplace_color1,
        content: t('web.topbar.logout'),
        href: router.logout_path(),
        type: 'menuitem',
      },
    ];
  }
  return [];
};

const DEFAULT_RAILS_CONTEXT = {
  marketplace_color1: styleVariables['--customColorFallback'],
  marketplace_color2: styleVariables['--customColor2Fallback'],
  location: typeof window !== 'undefined' ? window.location.pathname : '/',
};

class Topbar extends Component {
  render() {
    const marketplaceContext = this.props.railsContext || DEFAULT_RAILS_CONTEXT;

    const menuProps = this.props.menu ?
      Object.assign({}, this.props.menu, {
        key: 'menu',
        name: t('web.topbar.menu'),
        identifier: 'Menu',
        menuLabelType: LABEL_TYPE_MENU,
        extraClasses: `${css.topbarMenu}`,
        content: this.props.menu.links.map((l) => (
          {
            active: l.link === marketplaceContext.location,
            activeColor: marketplaceContext.marketplace_color1,
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
        extraClasses: `${css.topbarMenu}`,
        extraClassesLabel: `${css.topbarLanguageMenuLabel}`,
        content: this.props.locales.available_locales.map((v) => (
          {
            active: v.locale_ident === this.props.locales.current_locale_ident,
            activeColor: marketplaceContext.marketplace_color1,
            content: v.locale_name,
            href: v.change_locale_uri,
            type: 'menuitem',
          }
        )),
      }) :
      {};

    const username = marketplaceContext.loggedInUsername || null;
    const mobileMenuProps = Object.assign({}, this.props.menu, {
      key: 'mobilemenu',
      name: t('web.topbar.menu'),
      identifier: 'Menu',
      menuLabelType: LABEL_TYPE_MENU,
      extraClasses: `${css.topbarMobileMenu}`,
      color: marketplaceContext.marketplace_color1,
      menuLinksTitle: t('web.topbar.menu'),
      menuLinks: this.props.menu.links.map((l) => (
        {
          active: l.link === marketplaceContext.location,
          activeColor: marketplaceContext.marketplace_color1,
          content: l.title,
          href: l.link,
          type: 'menuitem',
        }
      )),
      userLinksTitle: t('web.topbar.user'),
      userLinks: profileLinks(username, this.props.routes, marketplaceContext),
    });

    const newListingRoute = this.props.routes && this.props.routes.new_listing_path ?
            this.props.routes.new_listing_path() :
            '#';

    return div({ className: css.topbar }, [
      this.props.menu ? r(MenuMobile, mobileMenuProps) : null,
      r(Logo, { ...this.props.logo, classSet: css.topbarLogo }),
      SEARCH_ENABLED && this.props.search ?
        r(SearchBar, {
          mode: this.props.search.mode,
          keywordPlaceholder: this.props.search.keyword_placeholder,
          locationPlaceholder: this.props.search.location_placeholder,
          onSubmit: this.props.search.onSubmit || (() => {
            console.log('submit search'); // eslint-disable-line no-console
          }),
        }) :
        null,
      this.props.menu ? r(Menu, menuProps) : null,
      div({ className: css.topbarSpacer }),
      hasMultipleLanguages ? r(Menu, languageMenuProps) : null,
      this.props.avatarDropdown ?
        r(AvatarDropdown, {
          ...avatarDropdownProps(this.props.avatarDropdown, marketplaceContext.marketplace_color1),
          classSet: css.topbarAvatarDropdown,
        }) :
        div({ className: css.topbarAvatarDropdownPlaceholder }),
      this.props.newListingButton ?
        r(AddNewListingButton, {
          ...this.props.newListingButton,
          url: newListingRoute,
          customColor: marketplaceContext.marketplace_color1,
        }) :
        null,
    ]);
  }
}

const { string, object, shape, arrayOf } = PropTypes;

/* eslint-disable react/forbid-prop-types */
Topbar.propTypes = {
  logo: object.isRequired,
  search: object,
  avatarDropdown: object,
  menu: shape({
    links: arrayOf(shape({
      title: string.isRequired,
      link: string.isRequired,
    })),
  }),
  locales: PropTypes.shape({
    current_locale: string.isRequired,
    current_locale_ident: string.isRequired,
    available_locales: arrayOf(shape({
      locale_name: string.isRequired,
      locale_ident: string.isRequired,
      change_locale_uri: string.isRequired,
    })),
  }),
  newListingButton: object,
  routes,
  railsContext,
};

export default Topbar;
