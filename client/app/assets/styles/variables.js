/* eslint-env node */
/* eslint-disable no-magic-numbers */
const fontSizeTiny = '11px';
const fontSizeSmaller = '12px';
const fontSizeSmall = '13px';
const fontSize = '14px';
const fontSizeBig = '16px';

const fontSizeMobileSmaller = '14px';
const fontSizeMobileSmall = '15px';
const fontSizeMobile = '17px';

const textColor = 'rgb(82, 89, 97)';
const textColorFocus = 'rgb(0, 0, 0)';
const textColorGrey = 'rgb(122, 125, 128)';
const textColorLight = 'rgb(255, 255, 255)';
const textColorSelected = '#4a4a4a';
const backgroundLightColor = 'white';
const backgroundLightColorHover = 'rgba(169, 172, 176, 0.07)';
const backgroundColorGrey = '#F7F7F7';
const customColorFallback = '#4a90e2';
const customColor2Fallback = '#2ab865';
const alertColor = '#ff4e36';

const topbarBorderColor = 'rgba(169, 172, 176, 0.5)';
const topbarItemHeight = '44px';
const topbarMediumItemHeight = '36px';
const bodyPadding = '24px';

// With minimum z-index we try to avoid most clashes with rails components
const zIndexMinimum = 5;

const searchBarNarrowWidth = 326;
const searchBarWidth = 396;

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
  '--breakpointMedium': 660,
  '--breakpointLarge': 1200,
  '--breakpointSearchWide': 1200 + (searchBarWidth - searchBarNarrowWidth), // eslint-disable-line no-magic-numbers

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
  '--Topbar_tabletHeight': '60px',
  '--Topbar_mobileHeight': '50px',
  '--Topbar_padding': `0 ${bodyPadding}`,
  '--Topbar_paddingLanguageMenuVertical': '27.5px',
  '--Topbar_tabletPadding': `0 ${bodyPadding} 0 6px`,
  '--Topbar_mobilePadding': '0 1px 0 0',
  '--Topbar_itemSpacing': '24px',
  '--Topbar_mobileItemSpacing': '18px',
  '--Topbar_logoMinWidth': '168px',
  '--Topbar_logoMaxHeight': '40px',
  '--Topbar_logoMaxHeightTablet': '36px',
  '--Topbar_logoMaxHeightMobile': '32px',
  '--Topbar_fontFamily': "'Proxima Nova Soft', Helvetica, sans",
  '--Topbar_borderColor': 'rgba(0, 0, 50, 0.1)',

   // Must be at least 16px to avoid iOS from zooming in when focusing
   // on an input.
  '--Topbar_inputFontSizeMobile': fontSizeBig,
  '--Topbar_fontSize': fontSize,
  '--Topbar_fontSizeMobile': fontSizeMobile,

  '--Topbar_avatarSize': topbarItemHeight,
  '--Topbar_avatarPadding': '18px 0',
  '--Topbar_avatarTabletPadding': '12px 0',
  '--Topbar_avatarMobilePadding': '8px 0',

  // SearchBar
  '--SearchBar_narrowWidth': `${searchBarNarrowWidth}px`,
  '--SearchBar_width': `${searchBarWidth}px`,
  '--SearchBar_mobileHeight': '50px',
  '--SearchBar_height': topbarItemHeight,
  '--SearchBar_borderColor': topbarBorderColor,
  '--SearchBar_borderColorActive': textColorGrey,
  '--SearchBar_textColor': textColorGrey,
  '--SearchBar_textColorActive': 'rgb(82, 89, 97)',
  '--SearchBar_textColorFocus': 'rgb(28, 30, 33)',
  '--SearchBar_iconColor': textColorGrey,
  '--SearchBar_iconColorActive': 'rgb(82, 89, 97)',
  '--SearchBar_iconColorFocus': 'rgb(28, 30, 33)',
  '--SearchBar_textPaddingMobile': '0.63em',
  '--SearchBar_textPadding': '0.715em',
  '--SearchBar_sidePaddingMobile': '1.13em',
  '--SearchBar_sidePadding': '1.715em',
  '--SearchBar_inputFontWeight': '500',
  '--SearchBar_keywordInputWidth': '63%',
  '--SearchBar_keywordInputFocusWidth': '78%',
  '--SearchBar_formZIndex': zIndexMinimum + 1,
  '--SearchBar_focusContainerZIndex': zIndexMinimum,
  '--SearchBar_childZIndex': zIndexMinimum + 1,
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
  '--ProfileDropdown_zIndex': zIndexMinimum + 1,
  '--ProfileDropdown_rightOffset': bodyPadding,
  '--ProfileDropdown_textColor': textColor,
  '--ProfileDropdown_textColorFocus': textColorFocus,
  '--ProfileDropdown_logoutLinkColor': textColorGrey,
  '--ProfileDropdown_colorLight': textColorLight,
  '--ProfileDropdown_textLinkSize': pxToEms(13, 14),
  '--ProfileDropdown_arrowWidth': '18px',
  '--ProfileDropdown_topSeparation': '0px',
  '--ProfileDropdown_lineWidth': '2px',
  '--ProfileDropdown_fontSizeNotification': fontSizeSmaller,

  '--MenuItem_borderColor': topbarBorderColor,
  '--MenuItem_backgroundColorHover': backgroundLightColorHover,
  '--MenuItem_paddingTopbarVertical': pxToEms(13, 14),
  '--MenuItem_paddingTopbarHorizontalMin': pxToEms(13, 14),
  '--MenuItem_paddingTopbarHorizontal': pxToEms(24, 14),
  '--MenuItem_paddingOffScreenVertical': pxToEms(10, 17),
  '--MenuItem_paddingOffScreenHorizontal': pxToEms(24, 17),
  '--MenuItem_paddingOffScreenHorizontalTablet': pxToEms(36, 16),
  '--MenuItem_fontSize': fontSizeBig,
  '--MenuItem_textColor': textColor,
  '--MenuItem_textColorFocus': textColorFocus,
  '--MenuItem_textColorDefault': customColorFallback,
  '--MenuItem_textColorSelected': textColorSelected,
  '--MenuItem_letterSpacing': '0.09px',

  '--Menu_fontSize': fontSize,
  '--Menu_fontSizeSmall': fontSizeSmall,
  '--Menu_textColor': textColor,
  '--Menu_textColorFocus': textColorFocus,
  '--Menu_colorBackground': backgroundLightColor,
  '--Menu_borderColor': topbarBorderColor,
  '--Menu_boxShadow': '0px 2px 4px 0px rgba(0, 0, 0, 0.1)',
  '--Menu_iconPadding': pxToEms(5, 14),
  '--Menu_zIndex': zIndexMinimum,

  '--MenuPriority_height': '60px',
  '--MenuPriority_extraSpacingNoUnit': 24,
  '--MenuPriority_itemSpacing': '18px',
  '--MenuPriority_itemSpacingNoUnit': 18,
  '--MenuPriority_textColor': textColor,
  '--MenuPriority_textColorHover': textColorFocus,
  '--MenuPriority_fontSize': fontSize,
  '--MenuPriority_letterSpacing': '0.22px',
  '--MenuPriority_paddingVertical': '19px',

  // topbar can't control base font-size.
  '--Menu_labelPaddingVertical': '27px',

  '--MenuSection_titleColor': 'rgba(153, 153, 153, 0.5)',
  '--MenuSection_fontSizeTitle': fontSizeSmaller,
  '--MenuSection_paddingOffScreenVertical': pxToEms(10, 12),
  '--MenuSection_paddingOffScreenHorizontal': pxToEms(24, 12),
  '--MenuSection_paddingOffScreenHorizontalTablet': pxToEms(36, 12),
  '--MenuSection_marginOffScreenBottom': pxToEms(16, 17),
  '--MenuSection_marginOffScreenBottomTablet': pxToEms(28, 17),
  '--MenuSection_iconMargin': pxToEms(9, 12),

  '--MobileMenu_labelPaddingVertical': '18px',
  '--MobileMenu_labelPaddingHorizontal': '18px',
  '--MobileMenu_offscreenMenuWidth': '288px',
  '--MobileMenu_offscreenHeaderItemHeight': '44px',
  '--MobileMenu_offscreenFooterBackgroundColor': backgroundColorGrey,
  '--MobileMenu_offscreenFooterMarginTop': pxToEms(14, 17),

  '--LanguagesMobile_fontSize': fontSizeMobileSmall,
  '--LanguagesMobile_fontSizeTablet': fontSizeMobileSmaller,
  '--LanguagesMobile_textColorDefault': customColorFallback,
  '--LanguagesMobile_textColorSelected': textColorSelected,
  '--LanguagesMobile_marginLanguageListRight': pxToEms(65, 15),
  '--LanguagesMobile_marginLanguageListLeft': pxToEms(24, 15),
  '--LanguagesMobile_marginLanguageListTop': pxToEms(6, 15),
  '--LanguagesMobile_marginLanguageListRightTablet': pxToEms(65, 14),
  '--LanguagesMobile_marginLanguageListLeftTablet': pxToEms(36, 14),
  '--LanguagesMobile_marginLanguageListTopTablet': pxToEms(5, 14),
  '--LanguagesMobile_marginTop': pxToEms(14, 15),
  '--LanguagesMobile_marginBottom': pxToEms(24, 15),
  '--LanguagesMobile_marginTopTablet': pxToEms(26, 14),
  '--LanguagesMobile_marginBottomTablet': pxToEms(36, 14),
  '--LanguagesMobile_paddingLanguageVertical': pxToEms(10, 15),
  '--LanguagesMobile_paddingLanguageRight': pxToEms(5, 15),
  '--LanguagesMobile_linkGap': pxToEms(10, 15),

  '--NotificationBadge_color': textColorLight,
  '--NotificationBadge_alertColor': alertColor,
  '--NotificationBadge_fontSize': fontSizeSmaller,
  '--NotificationBadge_fontSizeSmall': fontSizeTiny,

  '--AddNewListingButton_height': topbarItemHeight,
  '--AddNewListingButton_tabletHeight': topbarMediumItemHeight,
  '--AddNewListingButton_defaultColor': '#43A5CC',
  '--AddNewListingButton_textSize': fontSize,
  '--AddNewListingButton_textSizeTablet': fontSizeSmall,
  '--AddNewListingButton_textColor': '#fff',
  '--AddNewListingButton_maxTextWidth': '15em',
  '--AddNewListingButton_textPadding': '1.5em',
};
