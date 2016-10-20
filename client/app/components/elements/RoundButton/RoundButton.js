import r, { div } from 'r-dom';

import css from './RoundButton.css';

export default function RoundButton() {
  return div({ class: css.roundButton }, '>');
}
