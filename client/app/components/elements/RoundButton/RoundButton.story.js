import r from 'r-dom';
import { storify } from '../../Styleguide/withProps';

import RoundButton, { ArrowButton } from './RoundButton';

const { storiesOf } = storybookFacade;

const containerStyle = { style: { padding: '50px', display: 'inline-block', background: '#bbb' } };

storiesOf('Search results')
  .add('Round button', () => (
      r(storify(
        r(RoundButton, { diameter: '36px', content: '😎' }),
        containerStyle
      ))
  ))
  .add('Arrow button', () => (
      r(storify(
        r(ArrowButton, { direction: 'right' }),
        containerStyle
      ))
  ));
