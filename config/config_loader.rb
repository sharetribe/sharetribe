require 'yaml'
require 'ostruct'

module ConfigLoader
  DEFAULT_CONFIGS = "/config/config.defaults.yml"
  USER_CONFIGS = "/config/config.yml"

  module_function

  # Load configurations in order:
  # - default
  # - user
  # - env
  #
  # User configs override default configs and env configs override both user and default configs
  def load_app_config
    default_configs = read_yaml_file(DEFAULT_CONFIGS)
    user_configs = read_yaml_file(USER_CONFIGS)
    environment_configs = Maybe(ENV).or_else({})

    # Order: default, user, env
    config_order = [default_configs, user_configs, environment_configs]

    configs = config_order.inject { |a, b| a.merge(b) }
    OpenStruct.new(configs.symbolize_keys)
  end

  def read_yaml_file(file)
    abs_path = "#{Rails.root}/#{file}"
    file_content = if File.exists?(abs_path)
      YAML.load_file(abs_path)[Rails.env]
    end

    Maybe(file_content).or_else({})
  end
end
