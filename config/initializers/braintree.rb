# if Rails.env.development? or Rails.env.test?
  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.logger = Logger.new('log/braintree.log')
  Braintree::Configuration.merchant_id = "6bw7f6j84fxcypkg"
  Braintree::Configuration.public_key = "v9b2n8zkksbr58ph"
  Braintree::Configuration.private_key = "48e3792e4bce503fc5aaa8b97345aa93"
# else
#   Braintree::Configuration.environment = :production
#   Braintree::Configuration.merchant_id = ""
#   Braintree::Configuration.public_key = ""
#   Braintree::Configuration.private_key = ""
# end
