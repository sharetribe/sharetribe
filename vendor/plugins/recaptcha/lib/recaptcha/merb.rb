require 'recaptcha'

Merb::GlobalHelpers.send(:include, Recaptcha::ClientHelper)
Merb::Controller.send(:include, Recaptcha::Verify)
