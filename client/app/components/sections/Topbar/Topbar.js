import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';

import { t } from '../../../utils/i18n';
import { routes as routesProp, marketplaceContext } from '../../../utils/PropTypes';
import css from './Topbar.css';
import styleVariables from '../../../assets/styles/variables';

// elements
import AddNewListingButton from '../../elements/AddNewListingButton/AddNewListingButton';
import Logo from '../../elements/Logo/Logo';
import NotificationBadge from '../../elements/NotificationBadge/NotificationBadge';

// composites
import AvatarDropdown from '../../composites/AvatarDropdown/AvatarDropdown';
import LoginLinks from '../../composites/LoginLinks/LoginLinks';
import Menu from '../../composites/Menu/Menu';
import MenuMobile from '../../composites/MenuMobile/MenuMobile';
import SearchBar from '../../composites/SearchBar/SearchBar';

const profileDropdownActions = function profileDropdownActions(routes, username) {
  return username ?
  {
    inboxAction: routes.person_inbox_path(username),
    profileAction: routes.person_path(username),
    settingsAction: routes.person_settings_path(username),
    adminDashboardAction: routes.admin_path(),
    logoutAction: routes.logout_path(),
  } : null;
};

const avatarDropdownProps = (avatarDropdown, customColor, username, isAdmin, notificationCount, routes) => {
  const color = customColor || styleVariables['--customColorFallback'];
  const actions = {
    inboxAction: () => false,
    profileAction: () => false,
    settingsAction: () => false,
    adminDashboardAction: () => false,
    logoutAction: () => false,
    ...profileDropdownActions(routes, username),
  };
  const translations = {
    inbox: t('web.topbar.inbox'),
    profile: t('web.topbar.profile'),
    settings: t('web.topbar.settings'),
    adminDashboard: t('web.topbar.admin_dashboard'),
    logout: t('web.topbar.logout'),
  };
  return { actions, translations, customColor: color, isAdmin, notificationCount, ...avatarDropdown };
};

const LABEL_TYPE_MENU = 'menu';
const LABEL_TYPE_DROPDOWN = 'dropdown';

const SEARCH_ENABLED = false;

const profileLinks = function profileLinks(username, isAdmin, router, location, customColor, unReadMessagesCount) {
  if (username) {
    const notificationBadgeInArray = unReadMessagesCount > 0 ?
      [r(NotificationBadge, { className: css.notificationBadge, countClassName: css.notificationBadgeCount }, unReadMessagesCount)] :
      [];

    const links = [
      {
        active: router.person_inbox_path(username) === location,
        activeColor: customColor,
        content: [
          t('web.topbar.inbox'),
        ].concat(notificationBadgeInArray),
        href: router.person_inbox_path(username),
        type: 'menuitem',
      },
      {
        active: router.person_path(username) === location,
        activeColor: customColor,
        content: t('web.topbar.profile'),
        href: router.person_path(username),
        type: 'menuitem',
      },
      {
        active: `${router.person_path(username)}?show_closed=1` === location,
        activeColor: customColor,
        content: t('web.topbar.manage_listings'),
        href: `${router.person_path(username)}?show_closed=1`,
        type: 'menuitem',
      },
      {
        active: router.person_settings_path(username) === location,
        activeColor: customColor,
        content: t('web.topbar.settings'),
        href: router.person_settings_path(username),
        type: 'menuitem',
      },
      {
        active: router.logout_path() === location,
        activeColor: customColor,
        content: t('web.topbar.logout'),
        href: router.logout_path(),
        type: 'menuitem',
      },
    ];
    if (isAdmin) {
      links.unshift(
        {
          active: router.admin_path() === location,
          activeColor: customColor,
          content: t('web.topbar.admin_dashboard'),
          href: router.admin_path(),
          type: 'menuitem',
        });
    }
    return links;
  }
  return [];
};

const DEFAULT_CONTEXT = {
  marketplace_color1: styleVariables['--customColorFallback'],
  marketplace_color2: styleVariables['--customColor2Fallback'],
  loggedInUsername: null,
};

class Topbar extends Component {
  render() {
    const { location, marketplace_color1, loggedInUsername } = { ...DEFAULT_CONTEXT, ...this.props.marketplaceContext };

    const menuProps = this.props.menu ?
      Object.assign({}, this.props.menu, {
        key: 'menu',
        name: t('web.topbar.menu'),
        identifier: 'Menu',
        menuLabelType: LABEL_TYPE_MENU,
        content: this.props.menu.links.map((l) => (
          {
            active: l.link === location,
            activeColor: marketplace_color1,
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
        extraClassesLabel: `${css.topbarLanguageMenuLabel}`,
        content: this.props.locales.available_locales.map((v) => (
          {
            active: v.locale_ident === this.props.locales.current_locale_ident,
            activeColor: marketplace_color1,
            content: v.locale_name,
            href: v.change_locale_uri,
            type: 'menuitem',
          }
        )),
      }) :
      {};

    const newListingRoute = this.props.routes && this.props.routes.new_listing_path ?
            this.props.routes.new_listing_path() :
            '#';
    const profileRoute = this.props.routes && this.props.routes.person_path && loggedInUsername ?
            this.props.routes.person_path(loggedInUsername) :
            null;
    const mobileMenuAvatarProps = this.props.avatarDropdown && loggedInUsername ?
            { ...this.props.avatarDropdown.avatar, ...{ url: profileRoute } } :
            null;
    const isAdmin = this.props.isAdmin && loggedInUsername;

    const mobileMenuLanguageProps = hasMultipleLanguages ?
      Object.assign({}, {
        name: t('web.topbar.language'),
        color: marketplace_color1,
        links: this.props.locales.available_locales.map((locale) => (
          {
            href: locale.change_locale_uri,
            content: locale.locale_name,
            active: locale.locale_ident === this.props.locales.current_locale_ident,
            activeColor: marketplace_color1,
          }
        )),
      }) :
      null;


    const pathParams = { return_to: location };
    const loginRoute = this.props.routes.login_path ? this.props.routes.login_path(pathParams) : '#';
    const signupRoute = this.props.routes.sign_up_path ? this.props.routes.sign_up_path() : '#';

    const mobileMenuProps = this.props.menu ?
      Object.assign({}, this.props.menu, {
        key: 'mobilemenu',
        name: t('web.topbar.menu'),
        identifier: 'Menu',
        menuLabelType: LABEL_TYPE_MENU,
        color: marketplace_color1,
        extraClasses: `${css.topbarMobileMenu}`,
        menuLinksTitle: t('web.topbar.menu'),
        menuLinks: this.props.menu.links.map((l) => (
          {
            active: l.link === location,
            activeColor: marketplace_color1,
            content: l.title,
            href: l.link,
            type: 'menuitem',
          }
        )),
        userLinksTitle: t('web.topbar.user'),
        userLinks: profileLinks(loggedInUsername, isAdmin, this.props.routes, location, marketplace_color1, this.props.unReadMessagesCount),
        languages: mobileMenuLanguageProps,
        avatar: mobileMenuAvatarProps,
        newListingButton: this.props.newListingButton ?
          { ...this.props.newListingButton, ...{ url: newListingRoute, mobileLayoutOnly: true } } :
          null,
        loginLinks: {
          loginUrl: loginRoute,
          signupUrl: signupRoute,
          customColor: marketplace_color1,
        },
        notificationCount: this.props.unReadMessagesCount,
      }) :
      {};

    return div({ className: css.topbar }, [
      this.props.menu ? r(MenuMobile, { ...mobileMenuProps, className: css.topbarMobileMenu }) : null,
      r(Logo, { ...this.props.logo, classSet: css.topbarLogo, color: marketplace_color1 }),
      div({ className: css.topbarMediumSpacer }),
      SEARCH_ENABLED && this.props.search ?
        r(SearchBar, {
          mode: this.props.search.mode,
          keywordPlaceholder: this.props.search.keyword_placeholder,
          locationPlaceholder: this.props.search.location_placeholder,
          onSubmit: this.props.search.onSubmit || (() => {
            console.log('submit search'); // eslint-disable-line no-console
          }),
        }) :
        div({ className: css.topbarMobileSearchPlaceholder }),
      this.props.menu ? r(Menu, { ...menuProps, className: css.topbarMenu }) : null,
      div({ className: css.topbarSpacer }),
      hasMultipleLanguages ? r(Menu, {
        ...languageMenuProps,
        className: {
          [css.topbarMenu]: true,
          [css.topbarLanguageMenu]: true,
        } }) : null,
      this.props.avatarDropdown && loggedInUsername ?
        r(AvatarDropdown, {
          ...avatarDropdownProps(this.props.avatarDropdown, marketplace_color1,
                                 loggedInUsername, this.props.isAdmin, this.props.unReadMessagesCount, this.props.routes),
          classSet: css.topbarAvatarDropdown,
        }) :
        r(LoginLinks, {
          loginUrl: loginRoute,
          signupUrl: signupRoute,
          customColor: marketplace_color1,
          className: css.topbarLinks,
        }),
      this.props.newListingButton ?
        r(AddNewListingButton, {
          ...this.props.newListingButton,
          className: css.topbarListingButton,
          url: newListingRoute,
          customColor: marketplace_color1,
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
  routes: routesProp,
  marketplaceContext,
  isAdmin: PropTypes.bool,
  unReadMessagesCount: PropTypes.number,
};

export default Topbar;
