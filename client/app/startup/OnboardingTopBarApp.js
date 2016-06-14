import r from 'r-dom';
import { initialize as initializeI18n } from '../utils/i18n';
import OnboardingTopBar from '../components/sections/OnboardingTopBar/OnboardingTopBar';
import { subset } from '../utils/routes';

export default (props, railsContext) => {
  initializeI18n(railsContext.i18nLocale, railsContext.i18nDefaultLocale, process.env.NODE_ENV);

  const routes = subset([
    'admin_getting_started_guide',
    'admin_getting_started_guide',
    'admin_getting_started_guide_slogan_and_description',
    'admin_getting_started_guide_cover_photo',
    'admin_getting_started_guide_filter',
    'admin_getting_started_guide_paypal',
    'admin_getting_started_guide_listing',
    'admin_getting_started_guide_invitation',
  ], { locale: railsContext.i18nLocale });

  const combinedProps = Object.assign({}, props, { routes });

  return r(OnboardingTopBar, combinedProps);
};
