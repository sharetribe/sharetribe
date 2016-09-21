import { storiesOf, action, linkTo, specs } from './.storybook/mockApi';
import { expect } from 'chai';

global.storybookFacade = { storiesOf, action, linkTo, specs, expect };

import { jsdom } from 'jsdom';

global.document = jsdom('<!doctype html><html><body></body></html>');
global.window = document.defaultView;
global.navigator = global.window.navigator;
