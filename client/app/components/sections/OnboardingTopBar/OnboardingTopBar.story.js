import withProps from '../../Styleguide/withProps';

import OnboardingTopBar from './OnboardingTopBar';

const { storiesOf } = storybookFacade;

const noop = () => null;
const routes = {
  admin_getting_started_guide_path: noop,
  admin_getting_started_guide_slogan_and_description_path: noop,
  admin_getting_started_guide_cover_photo_path: noop,
  admin_getting_started_guide_filter_path: noop,
  admin_getting_started_guide_payment_path: noop,
  admin_getting_started_guide_listing_path: noop,
  admin_getting_started_guide_invitation_path: noop,
};


const defaultProps = {
  translations: {
    progress_label: 'Marketplace progress',
    next_step: 'Next',
    slogan_and_description: 'Add Slogan / Description',
    cover_photo: 'Upload cover photo',
    filter: 'Add Fields / Filters',
    payment: 'Accept payments',
    listing: 'Add a listing',
    invitation: 'Invite users',
  },
  progress: 83,
  next_step: 'payment',
  guide_root: '/fi/admin/communities/501/getting_started_guide',
  routes,
};

storiesOf('Onboarding')
  .add('TopBar: Not started', () => (
    withProps(OnboardingTopBar, Object.assign({}, defaultProps, {
      progress: 0,
      next_step: 'slogan_and_description',
    }))))
  .add('TopBar: In progress', () => (
    withProps(OnboardingTopBar, defaultProps)
    ))
  .add('TopBar: Complete', () => (
    withProps(OnboardingTopBar, Object.assign({}, defaultProps, {
      progress: 100,
      next_step: 'all_done',
    }))));
