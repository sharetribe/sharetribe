# Load the rails application
require File.expand_path('../application', __FILE__)

require 'yaml'
require 'ostruct'
APP_CONFIG = OpenStruct.new(YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env].symbolize_keys)  

# Initialize the rails application
Kassi::Application.initialize!
