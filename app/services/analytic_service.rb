module AnalyticService
  EVENT_LOGOUT = 'logout'.freeze
  EVENT_LISTING_CREATED = 'listing_created'.freeze
  EVENT_USER_INVITED = 'user_invited'.freeze

  INFO_MARKETPLACE_IDENT = :info_marketplace_ident
  ADMIN_CONFIRMED_EMAIL = :admin_confirmed_email
  ADMIN_CHANGED_SLOGAN = :admin_changed_slogan
  ADMIN_CHANGED_DESCRIPTION = :admin_changed_description
  ADMIN_CHANGED_COVER_PHOTO = :admin_changed_cover_photo
  ADMIN_CREATED_LISTING_FIELD = :admin_created_listing_field
  ORDER_TYPE_ONLINE_PAYMENT = :order_type_online_payment
  ORDER_TYPE_NO_ONLINE_PAYMENTS = :order_type_no_online_payments
  PAYMENT_PROVIDERS_AVAILABLE = :payment_providers_available
  ADMIN_CONFIGURED_PAYPAL_ACOUNT = :admin_configured_paypal_acount
  ADMIN_CONFIGURED_PAYPAL_FEES = :admin_configured_paypal_fees
  ADMIN_CONFIGURED_STRIPE_API = :admin_configured_stripe_api
  ADMIN_CONFIGURED_STRIPE_FEES = :admin_configured_stripe_fees
  ADMIN_CREATED_LISTING = :admin_created_listing
  ADMIN_INVITED_USER = :admin_invited_user
  ADMIN_DELETED_MARKETPLACE = :admin_deleted_marketplace
  ADMIN_CONFIGURED_FACEBOOK_CONNECT = :admin_configured_facebook_connect
  ADMIN_CONFIGURED_OUTGOING_EMAIL = :admin_configured_outgoing_email
end
