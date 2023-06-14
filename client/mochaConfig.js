import { storiesOf, action, linkTo, specs } from './.storybook/mockApi';
import chai, { expect } from 'chai';
import chaiEnzyme from 'chai-enzyme';
import { initialize as initializeI18n } from './app/utils/i18n';

chai.use(chaiEnzyme());

global.storybookFacade = { storiesOf, action, linkTo, specs, expect };

import { jsdom } from 'jsdom';

// Enzyme fix: load a document into the global scope before requiring React
global.document = jsdom('<!doctype html><html><body></body></html>');
global.window = global.document.defaultView;
Object.keys(global.document.defaultView).forEach((property) => {
  if (typeof global[property] === 'undefined') {
    global[property] = global.document.defaultView[property];
  }
});
global.navigator = global.window.navigator;

const localeInfo = { ident: 'en', name: 'English', language: 'en', region: 'US' };
initializeI18n('en', 'en', 'development', localeInfo);
