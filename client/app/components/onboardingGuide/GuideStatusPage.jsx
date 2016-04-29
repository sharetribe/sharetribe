import React, { PropTypes } from 'react';
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


  const todoDescPartial = (
    <div>
      <p className={css.description} >
        {props.t('description_p1')}
      </p>
      <p className={css.description} >
        {props.t('description_p2')}
      </p>
    </div>
    );

  const doneDescPartial = (
    <p className={css.description}
      dangerouslySetInnerHTML={{ __html: props.t('congratulation') }}
    ></p>
    );

  const description = props.nextStep ? todoDescPartial : doneDescPartial;
  return (
    <div className="container">
      <h2 className={css.title} >{title}</h2>

      {description}

      <hr className={css.sectionSeparator} />

      <ul className={css.stepList} >
        <li className={css.stepListItemDone}>
          <span className={css.stepListLink}>
            <span className={css.stepListCheckbox}></span>
            {props.t('create_your_marketplace')}
          </span>
        </li>
        {Object.keys(onboardingData).map((key) => {
          const stepListItem = onboardingData[key].complete ?
            css.stepListItemDone :
            css.stepListItem;
          return (
            <li className={stepListItem} key={key} >
              <a className={css.stepListLink}
                onClick={(e) => handleClick(e, `/${onboardingData[key].sub_path}`)}
                href={`${props.initialPath}/${onboardingData[key].sub_path}`}
              >
                <span className={css.stepListCheckbox}></span>
                {props.t(key)}
              </a>
            </li>
            );
        })}
      </ul>
      {props.nextStep ?
        <a onClick={(e) => handleClick(e, `/${props.nextStep.link}`)}
          href={`${props.initialPath}/${props.nextStep.link}`}
          className={css.nextButton}
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
  infoIcon: PropTypes.string.isRequired,
  nextStep: React.PropTypes.oneOfType([
    PropTypes.shape({
      title: PropTypes.string.isRequired,
      link: PropTypes.string.isRequired,
    }),
    PropTypes.bool.isRequired,
  ]).isRequired,
  onboarding_data: PropTypes.objectOf(PropTypes.shape({
    info_image: PropTypes.string,
    link: PropTypes.string,
    complete: PropTypes.bool.isRequired,
  })).isRequired,
  t: PropTypes.func.isRequired,
};

export default GuideStatusPage;
