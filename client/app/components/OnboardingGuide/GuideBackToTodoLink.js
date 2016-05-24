import { PropTypes } from 'react';
import { a } from 'r-dom';
import css from './OnboardingGuide.css';
import { t } from '../../utils/i18n';
import { Routes } from '../../utils/routes';

const GuideBackToTodoLink = (props) => {

  const guideRoot = Routes.admin_getting_started_guide_path();

  const handleClick = function handleClick(e, path) {
    e.preventDefault();
    props.changePage(path);
  };

  return a({
    className: css.backLink,
    onClick: (e) => handleClick(e, ''),
    href: guideRoot,
  }, `‹ ${t('web.admin.onboarding.guide.back_to_todo')}`);
};

GuideBackToTodoLink.propTypes = {
  changePage: PropTypes.func.isRequired,
};

export default GuideBackToTodoLink;
