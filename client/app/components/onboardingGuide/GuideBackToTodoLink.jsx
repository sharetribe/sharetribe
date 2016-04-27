import React, { PropTypes } from 'react';
import css from './styles.scss';

const GuideBackToTodoLink = (props) => {
  const handleClick = function handleClick(e, path) {
    e.preventDefault();
    props.changePage(path);
  };

  return (
      <a className={css.backLink}
        onClick={(e) => handleClick(e, '')}
        href={props.initialPath}
      >
        ‹ {props.t('back_to_todo')}
      </a>
  );
};
GuideBackToTodoLink.propTypes = {
  changePage: PropTypes.func.isRequired,
  initialPath: PropTypes.string.isRequired,
  t: PropTypes.func.isRequired,
};

export default GuideBackToTodoLink;
