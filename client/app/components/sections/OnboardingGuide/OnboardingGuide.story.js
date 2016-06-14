import { div } from 'r-dom';
import { storiesOf, action } from '@kadira/storybook';
import withProps from '../../Styleguide/withProps';

import GuideStatusPage from './GuideStatusPage';
import GuideSloganAndDescriptionPage from './GuideSloganAndDescriptionPage';
import GuideCoverPhotoPage from './GuideCoverPhotoPage';
import GuideFilterPage from './GuideFilterPage';
import GuidePaypalPage from './GuidePaypalPage';
import GuideListingPage from './GuideListingPage';
import GuideInvitationPage from './GuideInvitationPage';
import { all as allRoutes } from '../../../utils/routes';

const routes = allRoutes({ locale: 'en' });

const onboardingData = [
  {
    complete: false,
    step: 'slogan_and_description',
  },
  {
    complete: false,
    step: 'cover_photo',
  },
  {
    complete: false,
    step: 'filter',
  },
  {
    additional_info: {
      listing_shape_name: 'sell',
    },
    complete: false,
    step: 'paypal',
  },
  {
    complete: false,
    step: 'listing',
  },
  {
    complete: false,
    step: 'invitation',
  },
];
const statusPageProps = {
  changePage: function changePage(path) {
    action('sub page')(path);
  },
  name: 'John Doe',
  infoIcon: '<i class="ss-info"></i>',
  nextStep: {
    title: 'Add a cover photo',
    link: 'cover_photo',
  },
  onboarding_data: onboardingData,
  routes,
};

const sloganAndDescriptionProps = {
  changePage: function changePage(path) {
    action('back')(path);
  },
  infoIcon: '<i class="ss-info"></i>',
  name: 'John Doe',
  routes,
  pageData: {
    complete: true,
    step: 'slogan_and_description',
  },
};

const coverPhotoProps = {
  changePage: function changePage(path) {
    action('back')(path);
  },
  infoIcon: '<i class="ss-info"></i>',
  name: 'John Doe',
  routes,
  pageData: {
    complete: true,
    step: 'cover_photo',
  },
};

const filterProps = {
  changePage: function changePage(path) {
    action('back')(path);
  },
  infoIcon: '<i class="ss-info"></i>',
  name: 'John Doe',
  routes,
  pageData: {
    complete: true,
    step: 'filter',
  },
};

const paypalProps = {
  changePage: function changePage(path) {
    action('back')(path);
  },
  infoIcon: '<i class="ss-info"></i>',
  name: 'John Doe',
  routes,
  pageData: {
    complete: true,
    step: 'paypal',
    additional_info: {
      listing_shape_name: 'sell',
    },
  },
};

const listingProps = {
  changePage: function changePage(path) {
    action('back')(path);
  },
  infoIcon: '<i class="ss-info"></i>',
  name: 'John Doe',
  routes,
  pageData: {
    complete: true,
    step: 'listing',
  },
};
const invitationProps = {
  changePage: function changePage(path) {
    action('back')(path);
  },
  infoIcon: '<i class="ss-info"></i>',
  name: 'John Doe',
  routes,
  pageData: {
    complete: true,
    step: 'invitation',
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
