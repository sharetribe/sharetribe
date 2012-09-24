# Load the rails application
require File.expand_path('../application', __FILE__)

require 'yaml'
require 'ostruct'
APP_CONFIG = OpenStruct.new(YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env].merge(ENV).symbolize_keys)
# FIXME Temporary cludge to make Heroku work
APP_CONFIG.available_locales = [["English", "en"], ["Suomi", "fi"]] if APP_CONFIG.available_locales.nil?

# Initialize the rails application
Kassi::Application.initialize!
