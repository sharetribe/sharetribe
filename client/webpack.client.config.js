/* eslint-env node */

// const webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const config = require('./webpack.client.base.config');
const devBuild = process.env.NODE_ENV !== 'production';

const { replacePercentChar } = require('./webpackConfigUtil');
const assetHostEnv = typeof process.env.asset_host === 'string' ? `&asset_host=${process.env.asset_host}` : '';
const assetHost = replacePercentChar(assetHostEnv);

config.output = {
  filename: '[name]-bundle.js',
  path: `${__dirname}/../app/assets/webpack`,
  publicPath: '/assets/',
};

config.module = config.module || {};
config.module.rules = config.module.rules || [];
config.module.rules.push(
  {
    test: /\.js$/,
    loader: 'babel-loader',
    exclude: [/node_modules/, /routes\/routes.js/],
  },
  {
    test: /\.css$/,
    loader: ExtractTextPlugin.extract({
      use: [
        {
          loader: 'css-loader',
          options: {
            modules: true,
            localIdentName: '[name]__[local]__[hash:base64:5]',
            minimize: !devBuild,
            '-autoprefixer': !devBuild,
          },
        },
        {
          loader: 'postcss-loader',
        },
      ],
    }),
  },
  {
    test: /\.scss$/,
    loaders: ['style-loader', 'css-loader', 'sass-loader'],
  },
  {
    test: require.resolve('react'),
    loader: 'imports-loader',
  },
  {
    test: /\.(woff2?)$/,
    loader: 'url',
    options: {
      limit: 10000,
    },
  },
  {
    test: /\.(ttf|eot)$/,
    loader: 'file',
  },
  {
    test: /\.(jpe?g|png|gif|ico)$/,
    loader: 'customfile-loader',
    options: {
      limit: 10000,
      name: `[name]-[hash].[ext]${assetHost}`,

    },
  },
  {
    test: /\.json$/,
    loader: 'json-loader',
  },
  {
    test: /\.svg$/,
    loader: 'raw-loader',
  }
);

config.plugins.push(
  new ExtractTextPlugin({ filename: '[name]-bundle.css', disable: false, allChunks: true })
);

if (devBuild) {
  console.log('Webpack dev build for Rails'); // eslint-disable-line no-console
  config.devtool = 'eval-source-map';
} else {
  console.log('Webpack production build for Rails'); // eslint-disable-line no-console
}

module.exports = config;
