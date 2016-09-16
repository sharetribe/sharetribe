import { storiesOf, action, linkTo, describe, it, specs } from './.storybook/mockApi';
import { expect } from 'chai';
global.storiesOf = storiesOf;
global.action = action;
global.linkTo = linkTo;
global.describe = describe;
global.it = it;
global.expect = expect;
global.specs = specs;

import { jsdom } from 'jsdom';

global.document = jsdom('<!doctype html><html><body></body></html>');
global.window = document.defaultView;
global.navigator = global.window.navigator;
