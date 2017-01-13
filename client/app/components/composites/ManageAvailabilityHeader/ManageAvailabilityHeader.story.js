import withProps from '../../Styleguide/withProps';
import ManageAvailabilityHeader from './ManageAvailabilityHeader';

const { storiesOf } = storybookFacade;

storiesOf('Availability')
  .add('ManageAvailabilityHeader', () =>
       withProps(ManageAvailabilityHeader, {
         backgroundColor: '#347F9D',
         imageUrl: 'https://placehold.it/1024x1024',
         title: 'Pelago San Sebastian, in very good condition in Kallio',
         height: 400,
       }))
  .add('ManageAvailabilityHeader without image', () =>
       withProps(ManageAvailabilityHeader, {
         backgroundColor: '#347F9D',
         title: 'Pelago San Sebastian, in very good condition in Kallio',
         height: 400,
       }));
