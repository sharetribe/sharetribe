# Documentation

This directory contains Sharetribe documentation.

## Advanced configuration

Guides about advanced configurations.

#### [Using Amazon Simple Email Service with Simple Notification Service](./using-amazon-ses-with-sns.md)

This guide helps you to configure Amazon Simple Email Service to send emails and Simple Notification Service to receive bounce and spam notifications.

#### [Landing page](./landing-page.md)

This guide helps you to enable the landing page feature.

#### [Landing page JSON structure](./landing-page-structure.md)

This document describes the landing page structure JSON format.


## Coding guidelines

Coding guidelines followed in this project.

#### Supported browsers

We support last two major versions, with following exceptions: IE is supported from version 11 upwards, and iOS from version 8. Our [Browserslist](https://github.com/ai/browserslist) string can be found [here](https://github.com/sharetribe/sharetribe/blob/master/client/webpack.client.base.config.js#L65). At the time of writing it was `'last 2 versions', 'not ie < 11', 'not ie_mob < 11', 'ie >= 11', 'iOS >= 8'`, which evaluates to

```
[ 'chrome 51',
  'chrome 50',
  'edge 13',
  'edge 12',
  'firefox 47',
  'firefox 46',
  'ie 11',
  'ie_mob 11',
  'ios_saf 9.3',
  'ios_saf 9.0-9.2',
  'ios_saf 8.1-8.4',
  'ios_saf 8',
  'opera 37',
  'opera 36',
  'safari 9.1',
  'safari 9' ]
```

#### [Cucumber Do's and Don'ts](./cucumber-do-dont.md)

Some tips how to write Cucumber tests (and how not to).

#### [SCSS coding guidelines](./scss-coding-guidelines.md)

Documentation of SCSS coding guidelines and directory structure.


## Technical documentation

Technical documentation of different components.

#### [Delayed Job Priorities](./delayed-job-priorities.md)

List of commonly used Delayed Job priorities.

#### [Feature flags](./feature-flags.md)

How to use feature flags in the code and how to enable/disable them.

#### [Client-side routes](./js-routes.md)

Documentation of how to use Rails routes in JavaScript code.

#### [Client-side translations](./js-translations.md)

Documentation of how to use translation in JavaScript code.

#### [Method deprecator](./method-deprecator.md)

How to deprecate old methods in the code.

#### [Testing](./testing.md)

This guide contains information how to run tests.

## Process documentation

Documentation of the development process.

#### [How to handle Github issues](./how-to-handle-github-issues.md)

Documentation of the Github issue handling process followed by this project.

#### [Semantic versioning](./semantic-versioning.md)

Documentation of how Sharetribe applies Semantic versioning.
