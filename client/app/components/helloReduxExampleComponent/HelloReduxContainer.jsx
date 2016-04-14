import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import HelloReduxExampleComponent from './HelloReduxExampleComponent';

import * as helloReduxActions from '../../actions/helloReduxActions';

const HelloReduxContainer = ({ actions, data, railsContext }) =>
  <HelloReduxExampleComponent { ...{ actions, data, railsContext } } />;

HelloReduxContainer.propTypes = {
  actions: PropTypes.object.isRequired,
  data: PropTypes.object.isRequired,
  railsContext: PropTypes.object.isRequired,
};


// [mapStateToProps(state, [ownProps]): stateProps] (Function): If specified,
// the component will subscribe to Redux store updates. Any time it updates,
// mapStateToProps will be called. Its result must be a plain object*, and it
// will be merged into the component’s props. If you omit it, the component will
// not be subscribed to the Redux store. If ownProps is specified as a second
// argument, its value will be the props passed to your component, and
// mapStateToProps will be re-invoked whenever the component receives new props.
function mapStateToProps(state) {
  return {
    data: state.helloReduxData,
    railsContext: state.railsContext,
  };
}

// [mapDispatchToProps(dispatch, [ownProps]): dispatchProps] (Object or Function):
// If an object is passed, each function inside it will be assumed to be
// a Redux action creator. An object with the same function names, but with
// every action creator wrapped into a dispatch call so they may be invoked
// directly, will be merged into the component’s props. If a function is passed,
// it will be given dispatch. It’s up to you to return an object that somehow
// uses dispatch to bind action creators in your own way. (Tip: you may use the
// bindActionCreators() helper from Redux.)
// If you omit it, the default implementation just injects dispatch into your
// component’s props. If ownProps is specified as a second argument, its value
// will be the props passed to your component, and mapDispatchToProps will be
// re-invoked whenever the component receives new props.
function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(helloReduxActions, dispatch) };
}

// Don't forget to actually use connect!
export default connect(mapStateToProps, mapDispatchToProps)(HelloReduxContainer);
