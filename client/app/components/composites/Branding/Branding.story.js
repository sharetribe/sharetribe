import r from 'r-dom';
import { storify } from '../../Styleguide/withProps';

import Branding from './Branding';

const { storiesOf } = storybookFacade;

const containerStyle = { style: { minWidth: '100px', background: 'white' } };

storiesOf('Branding')
  .add('Default branding', () => (
      r(storify(
        r(Branding, { linkToSharetribe: 'https://www.sharetribe.com' }),
        containerStyle
      ))
  ));
