import { configure } from '@kadira/storybook';
import '../app/assets/styles/base.css';
import '../app/i18n/all';
import { initialize as initializeI18n } from '../app/utils/i18n';

import { storiesOf, action, linkTo, specs, describe, it, expect } from './facade';

global.storybookFacade = { storiesOf, action, linkTo, specs, expect };
global.describe = describe;
global.it = it;

// initializeI18n needs to know railsContext and node_env
const localeInfo = { ident: 'en', name: 'English', language: 'en', region: 'US' };
initializeI18n('en', 'en', process.env.NODE_ENV, localeInfo);

const loadStories = function loadStories() {
  require('../app/components/Styleguide/ColorsAndTypography.js');
  require('../app/components/sections/SearchPage/SearchPage.story.js');
  require('../app/components/sections/Topbar/Topbar.story.js');
  require('../app/components/sections/OnboardingTopBar/OnboardingTopBar.story.js');
  require('../app/components/sections/OnboardingGuide/OnboardingGuide.story.js');
  require('../app/components/composites/FlashNotification/FlashNotification.story.js');
  require('../app/components/composites/ListingCard/ListingCard.story.js');
  require('../app/components/composites/ListingCardPanel/ListingCardPanel.story.js');
  require('../app/components/composites/Menu/Menu.story.js');
  require('../app/components/composites/MenuMobile/MenuMobile.story.js');
  require('../app/components/composites/MenuMobile/LanguagesMobile.story.js');
  require('../app/components/composites/Branding/Branding.story.js');
  require('../app/components/composites/PageSelection/PageSelection.story.js');
  require('../app/components/composites/SideWinder/SideWinder.story.js');
  require('../app/components/elements/Avatar/Avatar.story.js');
  require('../app/components/elements/Logo/Logo.story.js');
  require('../app/components/elements/MenuItem/MenuItem.story.js');
  require('../app/components/elements/AddNewListingButton/AddNewListingButton.story.js');
  require('../app/components/elements/RoundButton/RoundButton.story.js');
};

configure(loadStories, module);
