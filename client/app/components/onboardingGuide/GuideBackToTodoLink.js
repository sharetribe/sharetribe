import { PropTypes } from 'react';
import { a } from 'r-dom';
import css from './styles.scss';

const GuideBackToTodoLink = (props) => {
  const handleClick = function handleClick(e, path) {
    e.preventDefault();
    props.changePage(path);
  };

  return a({
    className: css.backLink,
    onClick: (e) => handleClick(e, ''),
    href: props.initialPath,
  }, `‹ ${props.t('back_to_todo')}`);
};

GuideBackToTodoLink.propTypes = {
  changePage: PropTypes.func.isRequired,
  initialPath: PropTypes.string.isRequired,
  t: PropTypes.func.isRequired,
};

export default GuideBackToTodoLink;
