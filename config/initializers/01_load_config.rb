# This is named with 01_ because files are loaded in alphabetical order 
# and this needs to be loaded befor APP_CONFIG can be used elsewhere

# require 'yaml'
# require 'ostruct'
# APP_CONFIG = OpenStruct.new(YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env].symbolize_keys)