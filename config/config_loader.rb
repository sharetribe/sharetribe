require 'yaml'
require 'ostruct'
def load_app_config
  if File.exists?("#{Rails.root}/config/config.yml")
    conf_hash = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
  else
    #If there's no config file, this is probably Heroku installation, so use empty hash, where ENV is merged
    conf_hash = {}
  end
  conf = OpenStruct.new(conf_hash.merge(ENV).symbolize_keys)
  # FIXME Temporary cludge to make Heroku work
  #conf.available_locales = [["English", "en"], ["Suomi", "fi"]] if conf.available_locales.nil?
  return conf
end