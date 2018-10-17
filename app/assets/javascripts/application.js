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
//= require jquery-ui-1.9.2.custom
//= require jquery.ui.touch-punch.min.js
//= require jquery_ujs
//= require jquery.form
//= require jquery.validate
//= require jquery.pageless
//= require jquery.lightbox_me
//= require jquery.transit.min
//= require jquery.ui.widget
//= require load-image.min.js
//= require canvas-to-blob.min.js
//= require jquery.fileupload
//= require jquery.fileupload-process
//= require jquery.fileupload-validate
//= require jquery.fileupload-image
//= require autosize
//= require regenerator-runtime/runtime

//= require selectize-standalone.js
//= require datepicker/bootstrap-datepicker.js

// Allow IE8-9 to post cross domain XHR (required for image upload)
//= require jquery.iframe-transport.js

//= require fastclick

// Responsive helpers
// https://github.com/edenspiekermann/minwidth-relocate
//= require relocate
//= require minwidth

//= require infobubble
//= require sharetribe_common
//= require Bacon
//= require Bacon.jquery.min
//= require lodash.min
//= require utils
//= require kassi
//= require googlemaps
//= require map_label
//= require homepage
//= require order_manager
//= require ajax_status
//= require admin/expiration_notice
//= require admin/custom_fields
//= require admin/categories
//= require admin/manage_members
//= require admin/topbar_menu
//= require admin/community_customizations
//= require admin/listing_shapes
//= require admin/settings.js
//= require admin/emails.js
//= require admin/payment_preferences.js
//= require admin/transactions.js
//= require admin/testimonials.js
//= require payment_math
//= require dropdown
//= require jquery.nouislider
//= require range_filter
//= require translations
//= require image_uploader
//= require image_carousel
//= require thumbnail_stripe
//= require listing
//= require listing_images
//= require location_search
//= require datepicker
//= require follow
//= require paypal_account_settings
//= require transaction
//= require listing_form
//= require radio_buttons
//= require new_layout
//= require stripe_form
//= require analytics
//= require social-insurance-number
//= require_self
