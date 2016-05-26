/* eslint-env node */

const Promise = require('es6-promise');
Promise.polyfill();

const path = require('path');
const webpack = require('webpack');
const cssnext = require('postcss-cssnext');
const mixins = require('postcss-mixins');
const customProperties = require('postcss-custom-properties');
const cssVariables = require('./app/assets/styles/variables');

const devBuild = process.env.NODE_ENV !== 'production';
const nodeEnv = devBuild ? 'development' : 'production';

module.exports = {
  context: __dirname,
  entry: {

    // See use of 'vendor' in the CommonsChunkPlugin inclusion below.
    vendor: [
      'babel-polyfill',
      'es5-shim/es5-shim',
      'es5-shim/es5-sham',
    ],

    // This will contain the app entry points
    app: [
      './app/startup/clientRegistration',
    ],
  },
  resolve: {
    extensions: ['', '.js'],
  },
  plugins: [
    new webpack.IgnorePlugin(/i18n\/all.js/),

    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify(nodeEnv),
      },
    }),

    // https://webpack.github.io/docs/list-of-plugins.html#2-explicit-vendor-chunk
    new webpack.optimize.CommonsChunkPlugin({

      // This name 'vendor' ties into the entry definition
      name: 'vendor',

      // We don't want the default vendor.js name
      filename: 'vendor-bundle.js',

      // Passing Infinity just creates the commons chunk, but moves no modules into it.
      // In other words, we only put what's in the vendor entry definition in vendor-bundle.js
      minChunks: Infinity,
    }),
  ],
  postcss: [
    mixins({ mixinsFiles: path.join(__dirname, 'app/assets/styles/mixins.css') }),
    customProperties({ variables: cssVariables }),
    cssnext({ browsers: ['last 2 versions', 'not ie < 11', 'not ie_mob < 11', 'ie >= 11'] }),
  ],
};
