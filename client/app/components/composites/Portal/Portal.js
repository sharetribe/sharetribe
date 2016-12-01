/*
  # Portal

  Portal is a React component that is rendered outside the current
  render tree. It takes a parent element and children as props and
  creates a container element with the given children. This container
  element is then rendered to the given parent element. The children
  should be a single element.

  ## Example:

  const Modal = (props) => r(Portal, {
    parentElement: document.body,
  }, div({
    style: {
      position: 'absolute',
      top: 0,
      right: 0,
      bottom: 0,
      left: 0,
    },
  }, props.children));

*/

import { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';

import css from './Portal.css';

class Portal extends Component {
  componentDidMount() {
    this.element = document.createElement('div');
    this.element.className = css.root;
    this.props.parentElement.appendChild(this.element);
    this.componentDidUpdate();
  }
  componentDidUpdate() {
    ReactDOM.render(
      this.props.children,
      this.element
    );
  }
  componentWillUnmount() {
    ReactDOM.unmountComponentAtNode(this.element);
    this.props.parentElement.removeChild(this.element);
  }
  render() {
    return null;
  }
}

Portal.propTypes = {
  parentElement: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  children: PropTypes.object, // eslint-disable-line react/forbid-prop-types
};

export default Portal;
