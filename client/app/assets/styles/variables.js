/* eslint-env node */
const fontSizeSmaller = '12px';
const fontSizeSmall = '13px';
const fontSize = '14px';
const fontSizeBig = '16px';
const fontSizeMobile = '17px';

const textColor = 'rgb(82, 89, 97)';
const textColorFocus = 'rgb(0, 0, 0)';
const backgroundLightColor = 'white';
const backgroundLightColorHover = 'rgba(169, 172, 176, 0.07)';
const customColorFallback = '#a64c5d';
const customColor2Fallback = '#00a26c';

const topbarBorderColor = 'rgba(169, 172, 176, 0.5)';
const topbarItemHeight = '44px';
const bodyPadding = '24px';

const pxToEms = function pxToEms(px, againstFontSize) {
  const emValue = px / againstFontSize;
  return `${emValue}em`;
};

module.exports = {

  /*
   By default content based media queries should be used for
   responsiveness. However, some designs are based on certain fixed
   breakpoints.

   These breakpoints should not be used straight from variables. Use
   them with the custom media queries defined in media-queries.js.

   Example:

   .container {
     font-size: 2rem;

     @media (--medium-viewport) {
       font-size: 1.6rem;
     }

     @media (--large-viewport) {
       font-size: 1.4rem;
     }
   }
   */
  '--breakpointMedium': '601px',
  '--breakpointLarge': '1024px',

  '--baseFontSize': fontSize,
  '--baseFontSizeMobile': fontSizeMobile,

  '--fontSizeSmall': '0.875rem',
  '--fontSize': '1rem',
  '--fontSizeBig': '1.125rem',
  '--fontSizeTitle': '1.375rem',
  '--fontSizeInfo': '0.8125rem',
  '--fontSizeLogo': '1.75rem',

  '--lineHeight': '1.5rem',
  '--lineHeightBig': '2.25rem',
  '--lineHeightTitle': '1.875rem',
  '--lineHeightInfo': '1.38462rem',

  '--colorBackground': backgroundLightColor,
  '--color': '#3c3c3c',
  '--colorTitle': '#171717',
  '--colorActionText': '#4d998b',
  '--colorActionTextHover': '#348072',
  '--colorCompleted': '#646464',
  '--colorCompletedHover': '#4b4b4b',
  '--colorInfoText': 'gray',
  '--colorButtonText': 'white',
  '--colorButton': '#59b3a2',
  '--colorButtonHover': '#4d998b',
  '--colorButtonGhost': '#26806F',

  '--customColorFallback': customColorFallback,
  '--customColor2Fallback': customColor2Fallback,

  '--paddingButtonVertical': '0.626em',
  '--paddingButtonHorizontal': '1.875em',

  '--gutter': '1rem',

  '--verticalSpaceText': '0.75em',
  '--verticalSpaceTextSmall': '0.625em',
  '--verticalSpaceTextInfo': '0.375em',
  '--verticalSpaceElement': '2em',
  '--verticalSpaceElementBig': '2.5em',

  '--onboardingTopbarShadow': '0px 5px 8px 0px rgba(0, 0, 0, 0.06)',
  '--gradientStart': 'rgb(89,179,162)',
  '--gradientEnd': 'rgb(89,165,179)',

  '--widthRestriction': '550px',
  '--widthRestrictionPercentage': '90%',

  '--Topbar_height': '80px',
  '--Topbar_mobileHeight': '50px',
  '--Topbar_padding': `0 ${bodyPadding}`,
  '--Topbar_itemSpacing': '24px',
  '--Topbar_logoHeight': '40px',
  '--Topbar_textLogoMaxWidth': '20em',
  '--Topbar_fontFamily': "'Proxima Nova Soft', Helvetica, sans",

   // Must be at least 16px to avoid iOS from zooming in when focusing
   // on an input.
  '--Topbar_inputFontSizeMobile': fontSizeBig,
  '--Topbar_fontSize': fontSize,
  '--Topbar_fontSizeMobile': fontSizeMobile,

  '--Topbar_avatarSize': topbarItemHeight,
  '--Topbar_avatarPadding': '18px 0',
  '--Topbar_avatarMobilePadding': '3px 0',

  // SearchBar
  '--SearchBar_width': '396px',
  '--SearchBar_mobileHeight': '50px',
  '--SearchBar_height': topbarItemHeight,
  '--SearchBar_borderColor': topbarBorderColor,
  '--SearchBar_borderColorActive': 'rgb(122, 125, 128)',
  '--SearchBar_textColor': 'rgb(122, 125, 128)',
  '--SearchBar_textColorActive': 'rgb(82, 89, 97)',
  '--SearchBar_textColorFocus': 'rgb(28, 30, 33)',
  '--SearchBar_iconColor': 'rgb(122, 125, 128)',
  '--SearchBar_iconColorActive': 'rgb(82, 89, 97)',
  '--SearchBar_iconColorFocus': 'rgb(28, 30, 33)',
  '--SearchBar_textPaddingMobile': '0.63em',
  '--SearchBar_textPadding': '0.715em',
  '--SearchBar_sidePaddingMobile': '1.13em',
  '--SearchBar_sidePadding': '1.715em',
  '--SearchBar_inputFontWeight': '500',
  '--SearchBar_keywordInputWidth': '63%',
  '--SearchBar_keywordInputFocusWidth': '78%',
  '--SearchBar_formZIndex': '1',
  '--SearchBar_focusContainerZIndex': '0',
  '--SearchBar_childZIndex': '1',
  '--SearchBar_mobileTextColor': '#fff',
  '--SearchBar_mobileInputBorderColor': 'rgba(255, 255, 255, 0.3)',
  '--SearchBar_mobilePlaceholderColor': '#FCFCFC',
  '--SearchBar_mobileBackgroundColor': '#34495e',
  '--SearchBar_mobileButtonBackgroundColor': '#2C3e50',
  '--SearchBar_mobileTriangleSize': '8px',
  '--SearchBar_iconSize': '16px',
  '--SearchBar_iconTopMarginFix': '4px',

  // ProfileDropdown
  '--ProfileDropdown_border': `1px solid ${topbarBorderColor}`,
  '--ProfileDropdown_borderColor': topbarBorderColor,
  '--ProfileDropdown_zIndex': 1,
  '--ProfileDropdown_rightOffset': bodyPadding,

  '--MenuItem_borderColor': topbarBorderColor,
  '--MenuItem_backgroundColorHover': backgroundLightColorHover,
  '--MenuItem_paddingTopbarVertical': pxToEms(13, 14), // eslint-disable-line no-magic-numbers
  '--MenuItem_paddingTopbarHorizontal': pxToEms(24, 14), // eslint-disable-line no-magic-numbers
  '--MenuItem_paddingOffScreenVertical': pxToEms(10, 17), // eslint-disable-line no-magic-numbers
  '--MenuItem_paddingOffScreenHorizontal': pxToEms(24, 17), // eslint-disable-line no-magic-numbers
  '--MenuItem_textColor': textColor,
  '--MenuItem_textColorFocus': textColorFocus,
  '--MenuItem_textColorDefault': customColorFallback,
  '--MenuItem_textColorSelected': '#4a4a4a',
  '--MenuItem_letterSpacing': '0.09px',

  '--Menu_fontSize': fontSize,
  '--Menu_fontSizeSmall': fontSizeSmall,
  '--Menu_textColor': textColor,
  '--Menu_textColorFocus': textColorFocus,
  '--Menu_colorBackground': backgroundLightColor,
  '--Menu_borderColor': topbarBorderColor,
  '--Menu_boxShadow': '0px 2px 4px 0px rgba(0, 0, 0, 0.1)',
  '--Menu_iconPadding': '0.7em',
  '--Menu_zIndex': '1',

  // topbar can't control base font-size.
  '--Menu_labelPaddingVertical': '1.28571429em',
  '--Menu_labelPaddingHorizontal': '1.714285em',

  '--MenuSection_titleColor': 'rgba(153, 153, 153, 0.5)',
  '--MenuSection_fontSizeTitle': fontSizeSmaller,
  '--MenuSection_paddingOffScreenVertical': pxToEms(10, 12), // eslint-disable-line no-magic-numbers
  '--MenuSection_paddingOffScreenHorizontal': pxToEms(24, 12), // eslint-disable-line no-magic-numbers

  '--AddNewListingButton_height': topbarItemHeight,
  '--AddNewListingButton_defaultColor': '#43A5CC',
  '--AddNewListingButton_textColor': '#fff',
  '--AddNewListingButton_maxTextWidth': '15em',
  '--AddNewListingButton_textPadding': '1.5em',
};
