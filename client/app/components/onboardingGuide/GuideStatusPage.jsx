import React from 'react';
import _ from 'lodash';
import css from './styles.css';

const GuideStatusPage = (props) => {

  const handleClick = function(e, path) {
    e.preventDefault();
    props.setPushState({path}, path, path);
    props.changePage(path);
  }

  const onboarding_status = _.pickBy(props.onboarding_status, (v, k) => k != "community_id" );
  const title = props.t('title').replace(/\%\{(\w+)\}/g, props.name)

  return (
    <div className="container">
      <h1>{ title }</h1>
      <p>
        { props.t('description_p1') }
      </p>
      <p>
        { props.t('description_p2') }
      </p>

      <ul>
        <li className={css.stepList}>
          <input type="checkbox" name="onboarding-wizard" id="create-marketplace" checked readOnly />
          <a onClick={(e) => handleClick(e, "")} href={ props.initialPath } >
            Create marketplace
          </a>
        </li>
        { Object.keys(onboarding_status).map(function (key) {
            return (
              <li className={css.stepList} key={key} >
                <input type="checkbox" name="onboarding-wizard" id={key} checked={onboarding_status[key]} readOnly />
                <a onClick={(e) => handleClick(e, "/" + key)} href={ props.initialPath + "/" + key } >
                  Add {key}
                </a>
              </li>
            );
          })
        }
      </ul>
      <button>{ props.t('add_slogan') }</button>
    </div>
  );
};

export default GuideStatusPage;
