import r from 'r-dom';
import { storify } from '../../Styleguide/withProps';

import PageSelection from './PageSelection';

const { storiesOf } = storybookFacade;

const containerStyle = { style: { padding: '50px', display: 'inline-block', background: '#bbb' } };

storiesOf('Search results')
  .add('Page selection - first page', () => (
      r(storify(
        r(PageSelection, { currentPage: 1, totalPages: 2, location: 'foo' }),
        containerStyle
      ))
  ))
  .add('Page selection - second page', () => (
      r(storify(
        r(PageSelection, { currentPage: 2, totalPages: 3, location: 'foo' }),
        containerStyle
      ))
  ))
  .add('Page selection - last page', () => (
      r(storify(
        r(PageSelection, { currentPage: 3, totalPages: 3, location: 'foo' }),
        containerStyle
      ))
  ));
