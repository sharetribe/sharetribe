import { PropTypes } from 'react';
import r, { div } from 'r-dom';
import { t } from '../../../utils/i18n';

import Link from '../../elements/Link/Link';
import css from './LoginLinks.css';

export default function LoginLinks({ loginUrl, signupUrl, customColor }) {
  return div({
    className: 'LoginLinks',
    classSet: { [css.links]: true },
  }, [
    r(Link, {
      className: css.link,
      href: signupUrl,
      customColor,
    }, t('web.topbar.signup')),
    r(Link, {
      className: css.link,
      href: loginUrl,
      customColor,
    }, t('web.topbar.login')),
  ]);
}

LoginLinks.propTypes = {
  loginUrl: PropTypes.string.isRequired,
  signupUrl: PropTypes.string.isRequired,
  customColor: PropTypes.string,
};
