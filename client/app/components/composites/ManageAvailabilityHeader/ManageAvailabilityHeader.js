import { PropTypes } from 'react';
import { div, span } from 'r-dom';
import { t } from '../../../utils/i18n';
import { hexToRGB } from '../../../utils/colors';

import css from './ManageAvailabilityHeader.css';

const ManageAvailabilityHeader = (props) => {
  const bg = hexToRGB(props.backgroundColor);

  return div(
    {
      className: css.root,
      style: {
        height: `${props.height}px`,
      },
    },
    [
      div({
        className: css.backgroundLayer,
        style: {
          boxShadow: `inset 0px ${props.height}px rgba(${bg.r}, ${bg.g}, ${bg.b}, 0.9)`,
          backgroundImage: `url(${props.imageUrl})`,
        },
      }),
      div({ className: css.listingHeader }, [
        span({ className: css.availabilityHeader }, t('web.listings.edit_availability_header')),
        props.title,
      ]),
    ]
  );
};

ManageAvailabilityHeader.propTypes = {
  backgroundColor: PropTypes.string.isRequired,
  imageUrl: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
  height: PropTypes.number.isRequired,
};

export default ManageAvailabilityHeader;
