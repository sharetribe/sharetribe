# Supported browsers

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
