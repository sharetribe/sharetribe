require 'yaml'
require 'ostruct'
APP_CONFIG = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/config.yml")[Rails.env].symbolize_keys)