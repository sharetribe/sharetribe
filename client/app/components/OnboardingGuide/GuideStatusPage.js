import { PropTypes } from 'react';
import { div, p, h2, hr, ul, li, span, a } from 'r-dom';
import { t } from '../../utils/i18n';
import { Routes } from '../../utils/routes';

import css from './OnboardingGuide.css';

const GuideStatusPage = (props) => {

  const guideRoot = Routes.admin_getting_started_guide_path();

  const handleClick = function handleClick(e, path) {
    e.preventDefault();
    props.changePage(path);
  };

  const onboardingData = props.onboarding_data;

  const title = props.nextStep ?
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
          { href: 'http://support.sharetribe.com/knowledgebase/articles/892140-what-to-do-after-the-basic-setup-of-your-marketpla',
            target: '_blank',
            rel: 'noreferrer',
            alt: t('web.admin.onboarding.guide.status_page.congratulation_p1.knowledge_base_alt'),
          }),
        })),
    p({ className: css.description },
      t('web.admin.onboarding.guide.status_page.congratulation_p2.content',
        { marketplace_guide_link: a(
          { href: 'https://www.sharetribe.com/academy/guide/',
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
             href: 'mailto:support@sharetribe.com',
             title: t('web.admin.onboarding.guide.status_page.congratulation_p3.contact_support_title'),
           },
           t('web.admin.onboarding.guide.status_page.congratulation_p3.contact_support_link')),
         })),
  ]);

  const description = props.nextStep ? todoDescPartial : doneDescPartial;

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
      const key = step.step;
      const stepListItem = step.complete ?
              css.stepListItemDone :
              css.stepListItem;

      const titles = {
        slogan_and_description: 'web.admin.onboarding.guide.status_page.slogan_and_description',
        cover_photo: 'web.admin.onboarding.guide.status_page.cover_photo',
        filter: 'web.admin.onboarding.guide.status_page.filter',
        paypal: 'web.admin.onboarding.guide.status_page.paypal',
        listing: 'web.admin.onboarding.guide.status_page.listing',
        invitation: 'web.admin.onboarding.guide.status_page.invitation',
      };

      return li({ className: stepListItem, key }, [
        a({
          className: css.stepListLink,
          onClick: (e) => handleClick(e, `/${step.sub_path}`),
          href: `${guideRoot}/${step.sub_path}`,
        }, [
          span({ className: css.stepListCheckbox }),
          t(titles[key]),
        ]),
      ]);
    }))),

    props.nextStep ?
      a({
        className: css.nextButton,
        href: `${guideRoot}/${props.nextStep.link}`,
        onClick: (e) => handleClick(e, `/${props.nextStep.link}`),
      }, props.nextStep.title) :
      null,
  ]);
};

const { func, string, oneOf, shape, arrayOf, bool } = PropTypes;

GuideStatusPage.propTypes = {
  changePage: func.isRequired,
  name: string.isRequired,
  infoIcon: string.isRequired,
  nextStep: shape({
    title: string.isRequired,
    link: string.isRequired,
  }),
  onboarding_data: arrayOf(shape({
    step: oneOf([
      'slogan_and_description',
      'cover_photo',
      'filter',
      'paypal',
      'listing',
      'invitation',
      'all_done',
    ]),
    complete: bool.isRequired,
  })).isRequired,
};

export default GuideStatusPage;
