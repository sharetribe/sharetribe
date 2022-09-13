/* eslint-env node */

// const webpack = require('webpack');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
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
    loader: [
      {
        loader: MiniCssExtractPlugin.loader,
      },
      {
        loader: 'css-loader',
        options: {
          modules: {
            mode: 'local',
            localIdentName: '[name]__[local]__[hash:base64:5]',
          },
        },
      },
      {
        loader: 'postcss-loader',
      },
    ],
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
    loader: 'url-loader',
    options: {
      limit: 10000,
    },
  },
  {
    test: /\.(ttf|eot)$/,
    loader: 'file-loader',
  },
  {
    test: /\.(jpe?g|png|gif|ico)$/,
    loader: 'file-loader',
    options: {
      limit: 10000,
      name: `[name]-[hash].[ext]${assetHost}`,
    },
  },
  {
    test: /\.svg$/,
    loader: 'raw-loader',
  }
);

config.plugins.push(
  new MiniCssExtractPlugin({
    // Options similar to the same options in webpackOptions.output
    // both options are optional
    // chunkFilename: '[id].css',
    filename: '[name]-bundle.css',
  })
);

if (devBuild) {
  console.log('Webpack dev build for Rails'); // eslint-disable-line no-console
  config.devtool = 'eval-source-map';
} else {
  console.log('Webpack production build for Rails'); // eslint-disable-line no-console
}

module.exports = config;
