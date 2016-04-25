import React, { PropTypes } from 'react';
import scss from './styles.scss';

const GuideStatusPage = (props) => {
  const handleClick = function handleClick(e, path) {
    e.preventDefault();
    props.changePage(path);
  };

  const onboardingData = props.onboarding_data;
  // TODO: interpolating translation strings needs more thinking
  const title = props.nextStep ?
    props.t('title').replace(/\%\{(\w+)\}/g, props.name) :
    props.t('title_done');


  const todoDescPartial = (
    <div>
      <p className={scss.description} >
        {props.t('description_p1')}
      </p>
      <p className={scss.description} >
        {props.t('description_p2')}
      </p>
    </div>
    );

  const doneDescPartial = (
    <p className={scss.description}
      dangerouslySetInnerHTML={{ __html: props.t('congratulation') }}
    ></p>
    );

  const description = props.nextStep ? todoDescPartial : doneDescPartial;
  return (
    <div className="container">
      <h2 className={scss.title} >{title}</h2>

      {description}

      <hr className={scss.sectionSeparator} />

      <ul className={scss.stepList} >
        <li className={scss.stepListItemDone}>
          <span className={scss.stepListLink}>
            <span className={scss.stepListCheckbox}></span>
            Create marketplace
          </span>
        </li>
        {Object.keys(onboardingData).map((key) => {
          const stepListItem = onboardingData[key].complete ?
            scss.stepListItemDone :
            scss.stepListItem;
          return (
            <li className={stepListItem} key={key} >
              <a className={scss.stepListLink}
                onClick={(e) => handleClick(e, `/${key}`)}
                href={`${props.initialPath}/${key}`}
              >
                <span className={scss.stepListCheckbox}></span>
                {props.t(key)}
              </a>
            </li>
            );
        })}
      </ul>
      {props.nextStep ?
        <a onClick={(e) => handleClick(e, `/${props.nextStep.link}`)}
          href={`${props.initialPath}/${props.nextStep.link}`}
          className={scss.nextButton}
        >
          {props.nextStep.title}
        </a>
        : null}
    </div>
  );
};

GuideStatusPage.propTypes = {
  changePage: PropTypes.func.isRequired,
  initialPath: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  nextStep: React.PropTypes.oneOfType([
    PropTypes.shape({
      title: PropTypes.string.isRequired,
      link: PropTypes.string.isRequired,
    }),
    PropTypes.bool.isRequired,
  ]).isRequired,
  onboarding_data: PropTypes.objectOf(PropTypes.shape({
    infoImage: PropTypes.string,
    link: PropTypes.string,
    complete: PropTypes.bool.isRequired,
  })).isRequired,
  t: PropTypes.func.isRequired,
};

export default GuideStatusPage;
