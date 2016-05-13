import { PropTypes } from 'react';
import { div, p, h2, hr, ul, li, span, a } from 'r-dom';

import css from './styles.scss';

const GuideStatusPage = (props) => {
  const handleClick = function handleClick(e, path) {
    e.preventDefault();
    props.changePage(path);
  };

  const onboardingData = props.onboarding_data;

  // TODO: interpolating translation strings needs more thinking
  const title = props.nextStep ?
    props.t('title').replace(/%\{(\w+)\}/g, props.name) :
    props.t('title_done');

  const todoDescPartial = div([
    p({ className: css.description }, props.t('description_p1')),
    p({ className: css.description }, props.t('description_p2')),
  ]);

  const doneDescPartial = div([
    p({
      className: css.description,
      dangerouslySetInnerHTML: { __html: props.t('congratulation_p1') }, // eslint-disable-line react/no-danger
    }),
    p({
      className: css.description,
      dangerouslySetInnerHTML: { __html: props.t('congratulation_p2') }, // eslint-disable-line react/no-danger
    }),
    p({
      className: css.description,
      dangerouslySetInnerHTML: { __html: props.t('congratulation_p3') }, // eslint-disable-line react/no-danger
    }),
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
          props.t('create_your_marketplace'),
        ]),
      ]),
    ].concat(onboardingData.map((step) => {
      const key = step.step;
      const stepListItem = step.complete ?
              css.stepListItemDone :
              css.stepListItem;

      return li({ className: stepListItem, key }, [
        a({
          className: css.stepListLink,
          onClick: (e) => handleClick(e, `/${step.sub_path}`),
          href: `${props.initialPath}/${step.sub_path}`,
        }, [
          span({ className: css.stepListCheckbox }),
          props.t(key),
        ]),
      ]);
    }))),

    props.nextStep ?
      a({
        className: css.nextButton,
        href: `${props.initialPath}/${props.nextStep.link}`,
        onClick: (e) => handleClick(e, `/${props.nextStep.link}`),
      }, props.nextStep.title) :
      null,
  ]);
};

const { func, string, oneOf, shape, arrayOf, bool } = PropTypes;

GuideStatusPage.propTypes = {
  changePage: func.isRequired,
  initialPath: string.isRequired,
  name: string.isRequired,
  infoIcon: string.isRequired,
  nextStep: oneOf([
    shape({
      title: string.isRequired,
      link: string.isRequired,
    }),
    bool.isRequired,
  ]).isRequired,
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
    info_image: string,
    cta: string,
    complete: bool.isRequired,
  })).isRequired,
  t: func.isRequired,
};

export default GuideStatusPage;
