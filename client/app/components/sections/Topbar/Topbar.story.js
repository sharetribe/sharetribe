import r from 'r-dom';
import { mount } from 'enzyme';
import { storify } from '../../Styleguide/withProps';

import Topbar from './Topbar';
import { Image } from '../../../models/ImageModel';

const { storiesOf, action, specs, expect } = storybookFacade;

const containerStyle = { style: { minWidth: '600px', background: 'white' } };
const fakeRoute = () => '#';

const baseProps = {
  routes: {
    person_inbox_path: fakeRoute,
    person_path: fakeRoute,
    person_settings_path: fakeRoute,
    logout_path: fakeRoute,
    admin_path: fakeRoute,
  },
  logo: {
    href: 'http://example.com',
    text: 'Bikerrrs',
    image: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
    image_highres: 'https://s3.amazonaws.com/sharetribe-manual-assets/styleguide/bikerrrs-logo.png',
  },
  search: {
    mode: 'keyword_and_location',
    keyword_placeholder: 'Search...',
    location_placeholder: 'Location',
    onSubmit: action('submitting search'),
  },
  search_path: '#',
  menu: {
    limit_priority_links: null,
    links: [
      {
        link: 'http://example.com#about',
        title: 'About',
        priority: 0,
      },
      {
        link: 'http://suspicious.com#link',
        title: 'External',
        external: true,
        priority: 1,
      },
      {
        link: 'http://example.com#link2',
        title: 'Link2',
        priority: 2,
      },
      {
        link: 'http://example.com#longlink',
        title: 'Lorem ipsum dolor sit amet consectetur adepisci velit',
        priority: 3,
      },
    ],
  },
  locales: {
    current_locale: 'en',
    current_locale_ident: 'en',
    available_locales: [
      {
        change_locale_uri: 'http://example.com#en',
        locale_name: 'English',
        locale_ident: 'en',
      },
      {
        change_locale_uri: 'http://example.com#fi',
        locale_name: 'Suomi',
        locale_ident: 'fi',
      },
      {
        change_locale_uri: 'http://example.com#fr',
        locale_name: 'French',
        locale_ident: 'fr',
      },
      {
        change_locale_uri: 'http://example.com#de',
        locale_name: 'German',
        locale_ident: 'de',
      },
    ],
  },
  avatarDropdown: {
    actions: {
      inboxAction: action('clicked inbox'),
      profileAction: action('clicked profile'),
      settingsAction: action('clicked settings'),
      adminDashboardAction: action('clicked admin dashboard'),
      logoutAction: action('clicked logout'),
    },
    avatar: {
      image: new Image({ url: 'https://www.gravatar.com/avatar/d0865b2133d55fd507639a0fd1692b9a' }),
      givenName: 'First',
      familyName: 'Last',
    },
  },
  newListingButton: {
    text: 'Post a new listing',
  },
  i18n: {
    locale: 'en',
    defaultLocale: 'en',
  },
  marketplace: {
    marketplace_color1: '#64A',
    location: '/',
  },
  user: {
    loggedInUsername: 'foo',
    isAdmin: true,
  },
};

const loggedOut = (props) => ({
  ...props,
  user: {
    loggedInUsername: null,
    isAdmin: false,
  },
});

const storifyTopbar = (props) => r(storify(r(Topbar, props)), containerStyle);

const topbarWithSpecs = (props, spec) => {
  const component = r(Topbar, props);
  const mounted = mount(component);
  spec(mounted);
  return r(storify(component, containerStyle));
};

const noLoginLinks = (component) => {
  it('shouldn\'t contain login and signup links', () => {
    expect(component.text()).to.not.contain('login');
    expect(component.text()).to.not.contain('signup');
  });
  it('should contain logout link', () => {
    expect(component.text()).to.contain('Log out');
  });
};

const hasLoginLinks = (component) => {
  it('should contain login and signup links', () => {
    expect(component.text()).to.contain('Log in');
    expect(component.text()).to.contain('Sign up');
  });
  it('shouldn\'t contain logout link', () => {
    expect(component.text()).to.not.contain('Log out');
  });
};

const hasLogo = (component) => {
  it('should contain logo', () => {
    expect(component.find('.Logo')).to.have.length(1);
  });
};

const hasUserInitials = (component) => {
  it('should show user initials', () => {
    expect(component.find('.AvatarDropdown').text()).to.contain('FL');
  });
};

storiesOf('Top bar')
  .add('Basic state', () => (
    topbarWithSpecs(baseProps, (component) => {
      specs(() => describe('Basic topbar', () => {
        noLoginLinks(component);
      }));
    })))
  .add('Empty state', () => (
    topbarWithSpecs({
      logo: baseProps.logo,
      marketplace: {
        location: '/',
      },
      routes: baseProps.routes,
      search_path: baseProps.search_path,
    }, (component) => {
      specs(() => describe('Empty state', () => {
        hasLogo(component);
        hasLoginLinks(component);
      }));
    })))
  .add('Logged out', () => (
    storifyTopbar(loggedOut(baseProps))))
  .add('User without profile picture', () => (
    topbarWithSpecs({
      ...baseProps,
      avatarDropdown: {
        ...baseProps.avatarDropdown,
        avatar: {
          ...baseProps.avatarDropdown.avatar,
          image: null,
        },
      },
    }, (component) => {
      specs(() => describe('User without profile picture', () => {
        hasUserInitials(component);
      }));
    })))
  .add('Text logo', () => (
    storifyTopbar({ ...baseProps, logo: {
      href: 'http://example.com',
      text: 'My Marketplace',
    } })))
  .add('Long text logo', () => (
    storifyTopbar({ ...baseProps, logo: {
      href: 'http://example.com',
      text: 'My Marketplace with a looong name',
    } })))
  .add('Without search', () => (
    storifyTopbar({ ...baseProps, search: null })))
  .add('Without search, logged out', () => (
    storifyTopbar({ ...loggedOut(baseProps), search: null })))
  .add('With keyword search', () => (
    storifyTopbar({ ...baseProps, search: { mode: 'keyword' } })))
  .add('With location search', () => (
    storifyTopbar({ ...baseProps, search: { mode: 'location' } })))
  .add('With keyword and location search', () => (
    storifyTopbar({ ...baseProps, search: { mode: 'keyword_and_location' } })))
  .add('Logged in as admin', () => (
    storifyTopbar({ ...baseProps, isAdmin: true })));
