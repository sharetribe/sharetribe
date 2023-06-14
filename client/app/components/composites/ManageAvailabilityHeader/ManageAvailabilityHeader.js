import { PropTypes } from 'react';
import { div, span } from 'r-dom';
import { t } from '../../../utils/i18n';

import css from './ManageAvailabilityHeader.css';

const ManageAvailabilityHeader = (props) => div(
  {
    className: css.root,
  },
  [
    props.imageUrl ?
      div({
        className: css.imageLayer,
        style: { backgroundImage: `url(${props.imageUrl})` },
      }) :
      null,
    div({
      className: css.colorLayer,
      style: { backgroundColor: props.backgroundColor },
    }),
    div({ className: css.listingHeader }, [
      span({ className: css.availabilityHeader }, t('web.listings.edit_availability_header')),
      props.title,
    ]),
  ]
);

ManageAvailabilityHeader.propTypes = {
  backgroundColor: PropTypes.string.isRequired,
  imageUrl: PropTypes.string,
  title: PropTypes.string.isRequired,
};

export default ManageAvailabilityHeader;
