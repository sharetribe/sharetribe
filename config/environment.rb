# encoding: UTF-8

# Load the rails application
require File.expand_path('../application', __FILE__)
require File.expand_path('../config_loader', __FILE__)

APP_CONFIG = ConfigLoader.load_app_config

# Initialize the rails application
Kassi::Application.initialize!
