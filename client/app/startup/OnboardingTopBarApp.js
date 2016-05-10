import r from 'r-dom';
import { I18n } from '../utils/i18n';
import OnboardingTopBar from '../components/OnboardingTopBar/OnboardingTopBar';

export default (props, railsContext) => {
  I18n.locale = railsContext.i18nLocale;
  I18n.defaultLocale = railsContext.i18nDefaultLocale;

  return r(OnboardingTopBar, props);
};
