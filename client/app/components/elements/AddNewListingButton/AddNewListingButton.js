import { PropTypes } from 'react';
import { a, span } from 'r-dom';
import classNames from 'classnames';

import { className as classNameProp } from '../../../utils/PropTypes';
import { brightness } from '../../../utils/colors';
import { hasCSSFilters } from '../../../utils/featureDetection';

import * as variables from '../../../assets/styles/variables';
import css from './AddNewListingButton.css';

const HOVER_COLOR_BRIGHTNESS = 80;

export default function AddNewListingButton({ text, url, customColor, className, mobileLayoutOnly }) {
  const buttonText = `+ ${text}`;
  const color = customColor || variables['--AddNewListingButton_defaultColor'];

  // We have added hoverColor calucalation because IE11 doesn't support CSS filters yet
  // However, CSS filters are a better solution (hover works without js).
  // Since this better solution has already been written let's keep it.
  const hoverColor = brightness(color, HOVER_COLOR_BRIGHTNESS);

  return a({
    className: classNames(className, 'AddNewListingButton', css.button, { [css.responsiveLayout]: !mobileLayoutOnly }),
    href: url,
    title: text,
    onMouseOver: (e) => {
      if (!hasCSSFilters()) {
        e.currentTarget.getElementsByClassName('AddNewListingButton_background')[0].style.backgroundColor = hoverColor; // eslint-disable-line no-param-reassign
      }
    },
    onMouseOut: (e) => {
      if (!hasCSSFilters()) {
        e.currentTarget.getElementsByClassName('AddNewListingButton_background')[0].style.backgroundColor = color; // eslint-disable-line no-param-reassign
      }
    },
  }, [

    // Since we have to inline the marketplace color as the background
    // of this button (or text color on mobile), and the :hover styles
    // change the brightness of the dynamic background color, we have
    // to create a separate background container to avoid changing the
    // brightness of the text on top of the button.
    span({
      className: 'AddNewListingButton_background',
      classSet: { [css.backgroundContainer]: true },
      style: { backgroundColor: color },
    }),

    span({
      className: 'AddNewListingButton_mobile',
      classSet: { [css.mobile]: true },
      style: { color },
    }, buttonText),
    span({
      className: 'AddNewListingButton_desktop',
      classSet: { [css.desktop]: true },
    }, buttonText),
  ]);
}

AddNewListingButton.propTypes = {
  text: PropTypes.string.isRequired,
  url: PropTypes.string.isRequired,
  mobileLayoutOnly: PropTypes.bool,

  // Marketplace color or default color
  customColor: PropTypes.string,
  className: classNameProp,
};
