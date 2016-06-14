import { PropTypes } from 'react';
import { a } from 'r-dom';
import css from './OnboardingGuide.css';
import { t } from '../../../utils/i18n';

const GuideBackToTodoLink = (props) => {

  const guideRoot = props.routes.admin_getting_started_guide_path();

  const handleClick = function handleClick(e, page, path) {
    e.preventDefault();
    props.changePage(page, path);
  };

  return a({
    className: css.backLink,
    onClick: (e) => handleClick(e, null, guideRoot),
    href: guideRoot,
  }, `‹ ${t('web.admin.onboarding.guide.back_to_todo')}`);
};

const { func, shape } = PropTypes;

GuideBackToTodoLink.propTypes = {
  changePage: func.isRequired,
  routes: shape({
    admin_getting_started_guide_path: func.isRequired,
  }).isRequired,
};

export default GuideBackToTodoLink;
