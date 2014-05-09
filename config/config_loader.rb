require 'yaml'
require 'ostruct'
def load_app_config
  if File.exists?("#{Rails.root}/config/config.yml")

    conf_hash = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]

  else

    #If there's no config file, this is probably Heroku installation or running tests in CI
    if Rails.env.test?
      # use example file for Continuous integrations tests
      conf_hash = YAML.load_file("#{Rails.root}/config/config.example.yml")["test"]
    else
      conf_hash = {} # empty hash where Heroku env variables can be merged
    end
  end

  conf = OpenStruct.new(conf_hash.merge(ENV).symbolize_keys)
  # FIXME Temporary cludge to make Heroku work
  #conf.available_locales = [["English", "en"], ["Suomi", "fi"]] if conf.available_locales.nil?
  return conf
end
