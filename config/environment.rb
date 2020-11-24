# encoding: UTF-8

# Load the Rails application.
require_relative 'application'

require File.expand_path('../config_loader', __FILE__)

APP_CONFIG = ConfigLoader.load_app_config

# For invalid fields, Rails adds a wrapper div.field_with_error around the input field. Which sucks,
# because I didn't ask for any wrappers to magically appear and screw my form styles. So, disable them.
# See more: https://coderwall.com/p/s-zwrg
ActionView::Base.field_error_proc = proc do |html_tag, instance|
  wrap_field_with_error_classes = [
    LandingPageVersion::Section::Listings
  ]
  object = instance.object
  method_name = instance.instance_variable_get("@method_name")
  if wrap_field_with_error_classes.include?(object.class) &&
    instance.class == ActionView::Helpers::Tags::TextField
    "#{html_tag}<label class='error'>#{object.errors[method_name].join(', ')}</label>".html_safe
  else
    html_tag.html_safe
  end
end

# Initialize the rails application
Rails.application.initialize!
