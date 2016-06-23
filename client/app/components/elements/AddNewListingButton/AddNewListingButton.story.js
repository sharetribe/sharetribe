import { storiesOf } from '@kadira/storybook';
import withProps from '../../Styleguide/withProps';

import AddNewListingButton from './AddNewListingButton';

storiesOf('Add new listing button')
  .add('Default background color', () => (
    withProps(AddNewListingButton, {
      text: 'Post a new listing',
      url: '#',
    })))
  .add('Custom background color', () => (
    withProps(AddNewListingButton, {
      text: 'Some long text from translations here',
      url: '#',
      customColor: 'red',
    })));
