/* eslint-disable react/no-set-state */

import { Component, PropTypes } from 'react';
import r, { div, button, p } from 'r-dom';
import withProps from '../../Styleguide/withProps';
import SideWinder from './SideWinder';

const { storiesOf } = storybookFacade;

class WinderWinder extends Component {
  constructor(props) {
    super(props);
    this.state = { isOpen: props.isOpen };
  }
  render() {
    return div({ className: 'WinderWinder' }, [
      button({
        style: {
          float: 'right',
          marginRight: '1em',
          fontSize: '1.2em',
        },
        onClick: () => this.setState({ isOpen: !this.state.isOpen }),
      }, this.state.isOpen ? 'Hide SideWinder' : 'Show SideWinder'),
      r(SideWinder, {
        ...this.props,
        isOpen: this.state.isOpen,
        onClose: () => this.setState({ isOpen: false }),
      }, [
        div({
          style: {
            height: '100%',
            backgroundColor: '#eee',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          },
        }, [
          p({ style: { margin: 0 } }, 'This is the content of the SideWinder'),
        ]),
      ]),
    ]);
  }
}

WinderWinder.propTypes = {
  isOpen: PropTypes.bool.isRequired,
};

storiesOf('General')
  .add('SideWinder', () => (
    withProps(WinderWinder, {
      wrapper: document.getElementById('root'),
      width: 300,
      isOpen: false,
    })));
