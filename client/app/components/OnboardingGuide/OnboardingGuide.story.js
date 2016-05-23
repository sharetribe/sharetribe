import { div } from 'r-dom';
import { storiesOf, action } from '@kadira/storybook';
import withProps from '../Styleguide/withProps';

import GuideStatusPage from './GuideStatusPage';
import GuideSloganAndDescriptionPage from './GuideSloganAndDescriptionPage';
import GuideCoverPhotoPage from './GuideCoverPhotoPage';
import GuideFilterPage from './GuideFilterPage';
import GuidePaypalPage from './GuidePaypalPage';
import GuideListingPage from './GuideListingPage';
import GuideInvitationPage from './GuideInvitationPage';

const onboardingData = [
  {
    cta: '/en/admin/communities/1/edit_details',
    complete: false,
    step: 'slogan_and_description',
    sub_path: 'slogan_and_description',
  },
  {
    cta: '/en/admin/communities/1/edit_look_and_feel',
    complete: false,
    step: 'cover_photo',
    sub_path: 'cover_photo',
  },
  {
    cta: '/en/admin/custom_fields',
    complete: false,
    step: 'filter',
    sub_path: 'filter',
  },
  {
    cta: '/en/admin/paypal_preferences',
    alternative_cta: '/en/admin/listing_shapes/sell/edit',
    complete: false,
    step: 'paypal',
    sub_path: 'paypal',
  },
  {
    cta: '/en/listings/new',
    complete: false,
    step: 'listing',
    sub_path: 'listing',
  },
  {
    cta: '/en/invitations/new',
    complete: false,
    step: 'invitation',
    sub_path: 'invitation',
  },
];
const statusPageProps = {
  changePage: function changePage(path) {
    action('sub page')(path);
  },
  initialPath: '/en/admin/getting_started_guide',
  name: 'John Doe',
  infoIcon: '<i class="ss-info"></i>',
  nextStep: {
    title: 'Add a cover photo',
    link: 'cover_photo',
  },
  onboarding_data: onboardingData,
};

const sloganAndDescriptionProps = {
  changePage: function changePage(path) {
    action('back')(path);
  },
  infoIcon: '<i class="ss-info"></i>',
  initialPath: '/en/admin/getting_started_guide',
  name: 'John Doe',
  pageData: {
    complete: true,
    cta: '/en/admin/communities/1/edit_details',
    step: 'slogan_and_description',
    sub_path: 'slogan_and_description',
  },
};

const coverPhotoProps = {
  changePage: function changePage(path) {
    action('back')(path);
  },
  infoIcon: '<i class="ss-info"></i>',
  initialPath: '/en/admin/getting_started_guide',
  name: 'John Doe',
  pageData: {
    complete: true,
    cta: '/en/admin/communities/1/edit_look_and_feel',
    step: 'cover_photo',
    sub_path: 'cover_photo',
  },
};

const filterProps = {
  changePage: function changePage(path) {
    action('back')(path);
  },
  infoIcon: '<i class="ss-info"></i>',
  initialPath: '/en/admin/getting_started_guide',
  name: 'John Doe',
  pageData: {
    complete: true,
    cta: '/en/admin/custom_fields',
    step: 'filter',
    sub_path: 'filter',
  },
};

const paypalProps = {
  changePage: function changePage(path) {
    action('back')(path);
  },
  infoIcon: '<i class="ss-info"></i>',
  initialPath: '/en/admin/getting_started_guide',
  name: 'John Doe',
  pageData: {
    complete: true,
    cta: '/en/admin/paypal_preferences',
    alternative_cta: '/en/admin/listing_shapes/sell/edit',
    step: 'paypal',
    sub_path: 'paypal',
  },
};

const listingProps = {
  changePage: function changePage(path) {
    action('back')(path);
  },
  infoIcon: '<i class="ss-info"></i>',
  initialPath: '/en/admin/getting_started_guide',
  name: 'John Doe',
  pageData: {
    complete: true,
    cta: '/en/listings/new',
    step: 'listing',
    sub_path: 'listing',
  },
};
const invitationProps = {
  changePage: function changePage(path) {
    action('back')(path);
  },
  infoIcon: '<i class="ss-info"></i>',
  initialPath: '/en/admin/getting_started_guide',
  name: 'John Doe',
  pageData: {
    complete: true,
    cta: '/en/invitations/new',
    step: 'invitation',
    sub_path: 'invitation',
  },
};

const onboardingDataCompleted = onboardingData
  .map((d) => (
    Object.assign({}, d, { complete: true })
  ));

// Column max-width is 732px in admin panel
const columnWidth = { style: { maxWidth: '732px' } };

storiesOf('Onboarding guide')
  .add('Status page', () => (
    div(columnWidth,
      withProps(GuideStatusPage, statusPageProps)
    )))
  .add('Slogan and description page', () => (
    div(columnWidth,
      withProps(GuideSloganAndDescriptionPage, sloganAndDescriptionProps)
    )))
  .add('Cover photo page', () => (
    div(columnWidth,
      withProps(GuideCoverPhotoPage, coverPhotoProps)
    )))
  .add('Filter page', () => (
    div(columnWidth,
      withProps(GuideFilterPage, filterProps)
    )))
  .add('Paypal page', () => (
    div(columnWidth,
      withProps(GuidePaypalPage, paypalProps)
    )))
  .add('Listing page', () => (
    div(columnWidth,
      withProps(GuideListingPage, listingProps)
    )))
  .add('Invitation page', () => (
    div(columnWidth,
      withProps(GuideInvitationPage, invitationProps)
    )))
  .add('Status page complete', () => (
    div(columnWidth,
      withProps(GuideStatusPage, Object.assign({},
        statusPageProps,
        {
          onboarding_data: onboardingDataCompleted,
          nextStep: null,
        })
      )
    )));
