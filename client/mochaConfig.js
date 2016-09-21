import { storiesOf, action, linkTo, specs } from './.storybook/mockApi';
import { expect } from 'chai';

global.storybookFacade = { storiesOf, action, linkTo, specs, expect };

import { jsdom } from 'jsdom';

// Enzyme fix: load a document into the global scope before requiring React
global.document = jsdom('<!doctype html><html><body></body></html>');
global.window = global.document.defaultView;
global.navigator = global.window.navigator;
