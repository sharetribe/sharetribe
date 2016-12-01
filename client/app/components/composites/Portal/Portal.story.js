/* eslint-disable react/no-set-state */

import { Component } from 'react';
import r, { div, label, input, p } from 'r-dom';
import Portal from './Portal';
import withProps from '../../Styleguide/withProps';

const { storiesOf } = storybookFacade;

class PortalWrapper extends Component {
  constructor(props) {
    super(props);
    this.state = { portal1: true, portal2: false };
  }
  render() {

    const update = () => {
      this.setState({
        portal1: this.input1.checked,
        portal2: this.input2.checked,
      });
    };

    const labelProps = {
      style: { display: 'block' },
    };

    return div([
      p('Portal contents are rendered outside the current render tree.'),
      label(labelProps, [
        input({
          type: 'checkbox',
          checked: this.state.portal1,
          ref: (el) => {
            this.input1 = el;
          },
          onChange: update,
        }),
        'Show Portal 1',
      ]),
      label(labelProps, [
        input({
          type: 'checkbox',
          checked: this.state.portal2,
          ref: (el) => {
            this.input2 = el;
          },
          onChange: update,
        }),
        'Show Portal 2',
      ]),
      this.state.portal1 ? r(Portal, this.props, [p('Portal 1 contents.')]) : null,
      this.state.portal2 ? r(Portal, this.props, [p('Portal 2 contents.')]) : null,
    ]);
  }
}

storiesOf('General')
  .add('Portal', () => (
    withProps(PortalWrapper, {
      parentElement: document.getElementById('root'),
    })));
