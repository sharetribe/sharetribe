import { Component } from 'react';
import r, { div } from 'r-dom';

import css from './Topbar.css';

import Logo from './Logo';

class Topbar extends Component {
  render() {
    return div({ className: css.topbar }, [
      r(Logo, { ...this.props.logo, classSet: css.topbarLogo }),
    ]);
  }
}

export default Topbar;
