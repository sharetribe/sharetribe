/* eslint-env node */
const textColor = 'rgb(82, 89, 97)';
const textColorFocus = 'rgb(28, 30, 33)';
const borderColor = 'rgba(169, 172, 176, 0.5)';
const paddingTopbarVertical = '0.8125em';
const paddingTopbarHorizontal = '1.5em';

const topbarBorderColor = 'rgba(169, 172, 176, 0.5)';
const bodyPadding = '18px';

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

  '--baseFontSize': '14px',
  '--baseFontSizeMobile': '17px',

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

  '--colorBackground': 'white',
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
  '--Topbar_logoHeight': '40px',
  '--Topbar_fontFamily': "'Proxima Nova Soft', Helvetica, sans",

   // Must be at least 16px to avoid iOS from zooming in when focusing
   // on an input.
  '--Topbar_inputFontSizeMobile': '16px',
  '--Topbar_fontSize': '14px',

  '--Topbar_avatarSize': '44px',
  '--Topbar_avatarPadding': '18px 24px',
  '--Topbar_avatarMobilePadding': '3px 8px',

  // SearchBar
  '--SearchBar_width': '396px',
  '--SearchBar_mobileHeight': '50px',
  '--SearchBar_height': '44px',
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

  '--MenuItem_borderColor': borderColor,
  '--MenuItem_paddingTopbarVertical': paddingTopbarVertical,
  '--MenuItem_paddingTopbarHorizontal': paddingTopbarHorizontal,
  '--MenuItem_textColor': textColor,
  '--MenuItem_textColorFocus': textColorFocus,
  '--MenuItem_letterSpacing': '0.09px',
};
