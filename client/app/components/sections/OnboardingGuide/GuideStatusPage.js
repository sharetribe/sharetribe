import { PropTypes } from 'react';
import { div, p, h2, hr, ul, li, span, a } from 'r-dom';
import { t } from '../../../utils/i18n';

import css from './OnboardingGuide.css';

// Get link and title of next recommended onboarding step
const nextPageName = function nextPageName(data) {
  return (data.find((step) => !step.complete) || {}).step;
};

const GuideStatusPage = (props) => {

  const handleClick = function handleClick(e, page, path) {
    e.preventDefault();
    props.changePage(page, path);
  };

  const onboardingData = props.onboarding_data;

  const nextPage = nextPageName(onboardingData);

  const title = nextPage ?
        t('web.admin.onboarding.guide.status_page.title', { name: props.name }) :
        t('web.admin.onboarding.guide.status_page.title_done');

  const todoDescPartial = div([
    p({ className: css.description }, t('web.admin.onboarding.guide.status_page.description_p1')),
    p({ className: css.description }, t('web.admin.onboarding.guide.status_page.description_p2')),
  ]);

  const doneDescPartial = div([
    p({ className: css.description },
      t('web.admin.onboarding.guide.status_page.congratulation_p1.content',
        { knowledge_base_link: a(
          { href: 'https://help.sharetribe.com/configuration-and-how-to/what-to-do-after-the-basic-setup-of-your-marketplace',
            target: '_blank',
            rel: 'noreferrer',
            alt: t('web.admin.onboarding.guide.status_page.congratulation_p1.knowledge_base_alt'),
          },
          t('web.admin.onboarding.guide.status_page.congratulation_p1.knowledge_base_link')),
        })),
    p({ className: css.description },
      t('web.admin.onboarding.guide.status_page.congratulation_p2.content',
        { marketplace_guide_link: a(
          { href: 'https://www.sharetribe.com/academy/guide/?utm_source=marketplaceadminpanel&utm_medium=referral&utm_campaign=onboarding',
            target: '_blank',
            rel: 'noreferrer',
            alt: t('web.admin.onboarding.guide.status_page.congratulation_p2.marketplace_guide_alt'),
          },
          t('web.admin.onboarding.guide.status_page.congratulation_p2.marketplace_guide_link')),
        })),
    p({ className: css.description },
      t('web.admin.onboarding.guide.status_page.congratulation_p3.content',
         { contact_support_link: a(
           { 'data-uv-trigger': 'contact',
             href: 'mailto:help@sharetribe.com',
             title: t('web.admin.onboarding.guide.status_page.congratulation_p3.contact_support_title'),
           },
           t('web.admin.onboarding.guide.status_page.congratulation_p3.contact_support_link')),
         })),
  ]);

  const description = nextPage ? todoDescPartial : doneDescPartial;

  const { routes } = props;

  const links = {
    slogan_and_description: {
      link_title: 'web.admin.onboarding.guide.status_page.slogan_and_description',
      next_link_title: 'web.admin.onboarding.guide.next_step.slogan_and_description',
      path: routes.admin_getting_started_guide_slogan_and_description_path(),
    },
    cover_photo: {
      link_title: 'web.admin.onboarding.guide.status_page.cover_photo',
      next_link_title: 'web.admin.onboarding.guide.next_step.cover_photo',
      path: routes.admin_getting_started_guide_cover_photo_path(),
    },
    filter: {
      link_title: 'web.admin.onboarding.guide.status_page.filter',
      next_link_title: 'web.admin.onboarding.guide.next_step.filter',
      path: routes.admin_getting_started_guide_filter_path(),
    },
    payment: {
      link_title: 'web.admin.onboarding.guide.status_page.paypal',
      next_link_title: 'web.admin.onboarding.guide.next_step.paypal',
      path: routes.admin_getting_started_guide_payment_path(),
    },
    listing: {
      link_title: 'web.admin.onboarding.guide.status_page.listing',
      next_link_title: 'web.admin.onboarding.guide.next_step.listing',
      path: routes.admin_getting_started_guide_listing_path(),
    },
    invitation: {
      link_title: 'web.admin.onboarding.guide.status_page.invitation',
      next_link_title: 'web.admin.onboarding.guide.next_step.invitation',
      path: routes.admin_getting_started_guide_invitation_path(),
    },
  };

  return div({ className: 'container' }, [
    h2({ className: css.title }, title),
    description,
    hr({ className: css.sectionSeparator }),

    ul({ className: css.stepList }, [
      li({ className: css.stepListItemDone }, [
        span({ className: css.stepListLink }, [
          span({ className: css.stepListCheckbox }),
          t('web.admin.onboarding.guide.status_page.create_your_marketplace'),
        ]),
      ]),
    ].concat(onboardingData.map((step) => {
      const page = step.step;
      const stepListItem = step.complete ?
              css.stepListItemDone :
              css.stepListItem;

      return li({ className: stepListItem }, [
        a({
          className: css.stepListLink,
          onClick: (e) => handleClick(e, page, links[page].path),
          href: links[page].path,
        }, [
          span({ className: css.stepListCheckbox }),
          t(links[page].link_title),
        ]),
      ]);
    }))),

    nextPage ?
      a({
        className: css.nextButton,
        href: links[nextPage].path,
        onClick: (e) => handleClick(e, nextPage, links[nextPage].path),
      }, t(links[nextPage].next_link_title)) :
      null,
  ]);
};

const { func, string, oneOf, shape, arrayOf, bool } = PropTypes;

GuideStatusPage.propTypes = {
  changePage: func.isRequired,
  name: string.isRequired,
  infoIcon: string.isRequired,
  routes: shape({
    admin_getting_started_guide_slogan_and_description_path: func.isRequired,
    admin_getting_started_guide_cover_photo_path: func.isRequired,
    admin_getting_started_guide_filter_path: func.isRequired,
    admin_getting_started_guide_payment_path: func.isRequired,
    admin_getting_started_guide_listing_path: func.isRequired,
    admin_getting_started_guide_invitation_path: func.isRequired,
  }).isRequired,
  onboarding_data: arrayOf(shape({
    step: oneOf([
      'slogan_and_description',
      'cover_photo',
      'filter',
      'payment',
      'listing',
      'invitation',
      'all_done',
    ]),
    complete: bool.isRequired,
  })).isRequired,
};

export default GuideStatusPage;
