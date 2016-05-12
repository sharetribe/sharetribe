import { storiesOf } from '@kadira/storybook';
import r from 'r-dom';

import OnboardingTopBar from './OnboardingTopBar';

const defaultProps = {
  translations: {
    progress_label: 'Marketplace progress',
    next_step: 'Next',
    slogan_and_description: 'Add Slogan / Description',
    cover_photo: 'Upload cover photo',
    filter: 'Add Fields / Filters',
    paypal: 'Accept payments',
    listing: 'Add a listing',
    invitation: 'Invite users',
  },
  progress: 83,
  next_step: 'paypal',
  guide_root: '/fi/admin/communities/501/getting_started_guide',
};

storiesOf('Onboarding top bar')
  .add('Not started', () => (
    r(OnboardingTopBar, Object.assign({}, defaultProps, {
      progress: 0,
      next_step: 'slogan_and_description',
    }))))
  .add('In progress', () => (
    r(OnboardingTopBar, defaultProps)
    ))
  .add('Complete', () => (
    r(OnboardingTopBar, Object.assign({}, defaultProps, {
      progress: 100,
      next_step: 'all_done',
    }))));
