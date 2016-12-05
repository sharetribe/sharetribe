import { connect } from 'react-redux';
import r from 'r-dom';
import moment from 'moment';
import ManageAvailability from './ManageAvailability';
import * as cssVariables from '../../../assets/styles/variables';

const OPEN_HASH = 'edit-availability';

const log = (s) => () => {
  console.log('ManageAvailabilityContainer', s); // eslint-disable-line no-console
};

const ManageAvailabilityContainer = () =>
      r(ManageAvailability, {
        openWinderLinkHash: OPEN_HASH,
        hasChanges: false,
        onSave: log('save changes'),
        winder: {
          wrapper: document.querySelector('#sidewinder-wrapper'),
          isOpen: true,
          width: cssVariables['--ManageAvailability_width'],
          onClose: log('close winder'),
        },
        header: {
          backgroundColor: '347F9D',
          imageUrl: 'https://placehold.it/1024x1024',
          title: 'Pelago San Sebastian, in very good condition in Kallio',
          height: cssVariables['--ManageAvailabilityHeader_height'],
        },
        calendar: {
          initialMonth: moment().startOf('month'),
          blockedDays: [],
          reservedDays: [],
          onDayAllowed: log('allow date'),
          onDayBlocked: log('block date'),
          onMonthChanged: log('change month'),
        },
      });

const mapStateToProps = (state) => state;
const mapDispatchToProps = () => ({});

export default connect(mapStateToProps, mapDispatchToProps)(ManageAvailabilityContainer);
