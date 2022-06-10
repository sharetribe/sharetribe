// This file is used in production and tests to serve generated JS assets.
//
// In development mode, we use either:
// Procfile.static: Load static assets
// Procfile.hot: Use the Webpack Dev Server to provide assets. This allows for hot reloading of
// the JS and CSS via HMR.
//
// To understand which one is used, see app/views/layouts/application.html.erb

// NOTE: See config/initializers/assets.rb for some critical configuration regarding sprockets.
// Basically, in HOT mode, we do not include this file for
// Rails.application.config.assets.precompile
//= require vendor-bundle
//= require app-bundle

// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-3.6.0.min

//= require bootstrap
//= require waypoints.min
//= require swiper-bundle.min
//= require countdown.min
//= require jquery.counterup.min
//= require wow.min
//= require jquery.simpleLoadMore.min
//= require isotope.pkgd.min
//= require functions


//= require_self
