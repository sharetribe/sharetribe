import withProps from '../../Styleguide/withProps';

import AddNewListingButton from './AddNewListingButton';

const { storiesOf } = storybookFacade;

storiesOf('Top bar')
  .add('AddNewListingButton: default color', () => (
    withProps(AddNewListingButton, {
      text: 'Post a new listing',
      url: '#',
    })))
  .add('AddNewListingButton: custom color', () => (
    withProps(AddNewListingButton, {
      text: 'Some long text from translations here',
      url: '#',
      customColor: 'red',
    })));
