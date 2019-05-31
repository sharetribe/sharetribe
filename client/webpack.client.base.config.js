/* eslint-env node */

module.exports = {
  context: __dirname,
  entry: {

    // See use of 'vendor' in the CommonsChunkPlugin inclusion below.
    vendor: [
      'es6-shim',
      'whatwg-fetch',
    ],

    // This will contain the app entry points
    app: [
      './app/startup/clientRegistration',
    ],
  },
  resolve: {
    extensions: ['*', '.js'],
  },
  plugins: [],
  optimization: {
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendor',
          chunks: 'initial',
          enforce: true,
        },
      },
    },
  },
  output: {
    filename: 'vendor-bundle.js',
  },
};
