// This file is used in production and tests to serve generated JS assets.
//
// In development mode, we use either:
// Procfile.static: Load static assets
// Procfile.hot: Use the Webpack Dev Server to provide assets. This allows for hot reloading of
// the JS and CSS via HMR.
//

// NOTE: See config/initializers/assets.rb for some critical configuration regarding sprockets.
// Basically, in HOT mode, we do not include this file for
// Rails.application.config.assets.precompile
//= require vendor-bundle
//= require app-bundle

//= require fastclick
