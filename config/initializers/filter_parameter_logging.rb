# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :password2, :account_number, :routing_number, :address_street_address,
                                               :image, :wide_logo, :logo, :cover_photo, :small_cover_photo, :favicon,
                                               :"date_of_birth(3i)", :"date_of_birth(2i)", :"date_of_birth(1i)",
                                               :api_private_key, :api_publishable_key,
                                               :legal_name, :address_country, :address_city, :address_line1, :address_postal_code, :address_state,
                                               :"birth_date(3i)", :"birth_date(2i)", :"birth_date(1i)",
                                               :bank_account_number, :bank_routing_number, :ssn_last_4, :personal_id_number]

