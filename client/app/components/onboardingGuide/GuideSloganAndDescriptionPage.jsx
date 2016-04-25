import React, { PropTypes } from 'react';
import scss from './styles.scss';

const GuideSloganAndDescriptionPage = (props) => {
  const handleClick = function handleClick(e, path) {
    e.preventDefault();
    props.changePage(path);
  };

  return (
    <div className="container">
      <a className={scss.backLink}
        onClick={(e) => handleClick(e, '')}
        href={props.initialPath}
      >
        ‹ {props.t('back_to_todo')}
      </a>

      <h2 className={scss.title} >{props.t('title')}</h2>

      <p className={scss.description} >
        {props.t('description')}
      </p>

      <div className={scss.sloganImageContainer} >
        <img src={props.pageData.infoImage}
          className={scss.sloganImage}
          alt={props.t('info_image_alt')}
        />
      </div>

      <div className={scss.infoTextContainer} >
        <div className={scss.infoTextIcon} >
          <i className="ss-info"></i>
        </div>
        <div className={scss.infoTextContent} >
          {props.t('advice')}
        </div>
      </div>

      <a href={props.pageData.link}
        className={scss.nextButton}
      >
        {props.t('add_your_own')}
      </a>
    </div>
  );
};

GuideSloganAndDescriptionPage.propTypes = {
  changePage: PropTypes.func.isRequired,
  initialPath: PropTypes.string.isRequired,
  t: PropTypes.func.isRequired,
  pageData: PropTypes.shape({
    link: PropTypes.string.isRequired,
    infoImage: PropTypes.string.isRequired,
  }).isRequired,
};

export default GuideSloganAndDescriptionPage;
