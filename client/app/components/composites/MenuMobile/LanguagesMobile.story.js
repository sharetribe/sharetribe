import r from 'r-dom';
import { storify, defaultRailsContext } from '../../Styleguide/withProps';

import LanguagesMobile from './LanguagesMobile';

const { storiesOf } = storybookFacade;
const containerStyle = { style: { minWidth: '100px', background: 'white' } };

storiesOf('Top bar')
  .add('MenuMobile: language section', () => (
      r(storify(
        r(LanguagesMobile,
          {
            marketplaceContext: defaultRailsContext,
            name: 'Language',
            color: '#64A',
            links: [
              {
                href: '#',
                content: 'English',
                active: true,
                activeColor: '#4A4A4A',
              },
              {
                href: '#',
                content: 'German',
                active: false,
                activeColor: '#4A4A4A',
              },
              {
                href: '#',
                content: 'Spanish',
                active: false,
                activeColor: '#4A4A4A',
              },
              {
                href: '#',
                content: 'Finnish',
                active: false,
                activeColor: '#4A4A4A',
              },
            ],
          }
        ),
        containerStyle
      ))
  ));
