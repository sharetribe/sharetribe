import r from 'r-dom';
import { storify } from '../../Styleguide/withProps';

import RoundButton from './RoundButton';

const { storiesOf } = storybookFacade;

const containerStyle = { style: { padding: '50px', width: '32px', height: '32px', background: 'grey' } };

storiesOf('Search results')
  .add('Round button', () => (
      r(storify(
        r(RoundButton),
        containerStyle
      ))
  ));
