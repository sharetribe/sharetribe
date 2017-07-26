# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :password2, :account_number, :routing_number, :address_street_address,
                                               :image, :wide_logo, :logo, :cover_photo, :small_cover_photo, :favicon,
                                               :"date_of_birth(3i)", :"date_of_birth(2i)", :"date_of_birth(1i)", :"api_private_key", :"api_publishable_key"]
