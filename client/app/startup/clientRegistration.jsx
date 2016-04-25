import ReactOnRails from 'react-on-rails';
import ReduxApp from './ExampleReduxApp';
import Promise from 'es6-promise';

Promise.polyfill();

ReactOnRails.register({
  ReduxApp,
});

ReactOnRails.registerStore({
});
