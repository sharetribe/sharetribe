import r, { div } from 'r-dom';
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
    cta: "/en/admin/communities/1/edit_details",
    complete: false,
    step: 'slogan_and_description',
    sub_path: "slogan_and_description",
  },
  {
    cta: "/en/admin/communities/1/edit_look_and_feel",
    complete: false,
    step: 'cover_photo',
    sub_path: "cover_photo",
  },
  {
    cta: "/en/admin/custom_fields",
    complete: false,
    step: 'filter',
    sub_path: "filter",
  },
  {
    cta: "/en/admin/paypal_preferences",
    alternative_cta: "/en/admin/listing_shapes/sell/edit",
    complete: false,
    step: 'paypal',
    sub_path: "paypal",
  },
  {
    cta: "/en/listings/new",
    complete: false,
    step: 'listing',
    sub_path: "listing",
  },
  {
    cta: "/en/invitations/new",
    complete: false,
    step: 'invitation',
    sub_path: "invitation",
  },
];
const statusPageProps = {
  changePage: function() { console.log('asdf')},
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
  changePage: function() { console.log('asdf')},
  infoIcon: '<i class="ss-info"></i>',
  initialPath: '/en/admin/getting_started_guide',
  name: 'John Doe',
  pageData: {
    complete : true,
    cta : "/en/admin/communities/1/edit_details",
    step : "slogan_and_description",
    sub_path : "slogan_and_description",
  },
};

const coverPhotoProps = {
  changePage: function() { console.log('asdf')},
  infoIcon: '<i class="ss-info"></i>',
  initialPath: '/en/admin/getting_started_guide',
  name: 'John Doe',
  pageData: {
    complete : true,
    cta : "/en/admin/communities/1/edit_look_and_feel",
    step : "cover_photo",
    sub_path : "cover_photo",
  },
};

const filterProps = {
  changePage: function() { console.log('asdf')},
  infoIcon: '<i class="ss-info"></i>',
  initialPath: '/en/admin/getting_started_guide',
  name: 'John Doe',
  pageData: {
    complete : true,
    cta : "/en/admin/custom_fields",
    step : "filter",
    sub_path : "filter",
  },
};

const paypalProps = {
  changePage: function() { console.log('asdf')},
  infoIcon: '<i class="ss-info"></i>',
  initialPath: '/en/admin/getting_started_guide',
  name: 'John Doe',
  pageData: {
    complete : true,
    cta: "/en/admin/paypal_preferences",
    alternative_cta: "/en/admin/listing_shapes/sell/edit",
    step : "paypal",
    sub_path : "paypal",
  },
};

const listingProps = {
  changePage: function() { console.log('asdf')},
  infoIcon: '<i class="ss-info"></i>',
  initialPath: '/en/admin/getting_started_guide',
  name: 'John Doe',
  pageData: {
    complete : true,
    cta : "/en/listings/new",
    step : "listing",
    sub_path : "listing",
  },
};
const invitationProps = {
  changePage: function() { console.log('asdf')},
  infoIcon: '<i class="ss-info"></i>',
  initialPath: '/en/admin/getting_started_guide',
  name: 'John Doe',
  pageData: {
    complete : true,
    cta: "/en/invitations/new",
    step : "invitation",
    sub_path : "invitation",
  },
};

const onboardingDataCompleted = Object.assign([], onboardingData)
  .map( d => {
    return Object.assign({}, d, {complete: true});
  });

console.log('statusPageProps', statusPageProps);
console.log('statusPageCompletedProps', onboardingDataCompleted);

// Column max-width is 732px in admin panel
storiesOf('Onboarding guide')
  .add('Status page', () => (
    div({style: {maxWidth: '732px'}},
      withProps(GuideStatusPage, statusPageProps)
    )))
  .add('Slogan and description page', () => (
    div({style: {maxWidth: '732px'}},
      withProps(GuideSloganAndDescriptionPage, sloganAndDescriptionProps)
    )))
  .add('Cover photo page', () => (
    div({style: {maxWidth: '732px'}},
      withProps(GuideCoverPhotoPage, coverPhotoProps)
    )))
  .add('Filter page', () => (
    div({style: {maxWidth: '732px'}},
      withProps(GuideFilterPage, filterProps)
    )))
  .add('Paypal page', () => (
    div({style: {maxWidth: '732px'}},
      withProps(GuidePaypalPage, paypalProps)
    )))
  .add('Listing page', () => (
    div({style: {maxWidth: '732px'}},
      withProps(GuideListingPage, listingProps)
    )))
  .add('Invitation page', () => (
    div({style: {maxWidth: '732px'}},
      withProps(GuideInvitationPage, invitationProps)
    )))
  .add('Status page complete', () => (
    div({style: {maxWidth: '732px'}},
      withProps(GuideStatusPage, Object.assign({},
        statusPageProps,
        {
          onboarding_data: onboardingDataCompleted,
          nextStep: null,
        })
      )
    )));
