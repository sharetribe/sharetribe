
import r from 'r-dom';
import { storiesOf } from '@kadira/storybook';
import { storify, defaultRailsContext } from '../../Styleguide/withProps';

import LanguagesMobile from './LanguagesMobile';

const containerStyle = { style: { minWidth: '100px', background: 'white' } };

storiesOf('LanguagesMobile')
  .add('Basic state ', () => (
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
