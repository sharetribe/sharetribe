import r from 'r-dom';
import { storiesOf } from '@kadira/storybook';
import { storify } from '../../Styleguide/withProps';

import Branding from './Branding';

const containerStyle = { style: { minWidth: '100px', background: 'white' } };

storiesOf('Branding')
  .add('Default branding', () => (
      r(storify(
        r(Branding, { linkToSharetribe: 'https://www.sharetribe.com' }),
        containerStyle
      ))
  ));
