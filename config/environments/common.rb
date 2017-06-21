require_relative '../../lib/jsroutes_middleware.rb'

Rails.application.configure do

  str_to_lowercase_sym = ->(v) {
    if v.nil? || v.is_a?(Symbol)
      v
    else
      v.downcase.to_sym
    end
  }

  Config = EntityUtils.define_builder(
    [:asset_host, :string, :optional],
    [:eager_load, :bool, :mandatory, :str_to_bool],
    [:serve_static_files, :bool, :optional, :str_to_bool],
    [:log_level, transform_with: str_to_lowercase_sym, one_of: [:debug, :info, :warn, :error]],
    [:use_i18n_js_middleware, :bool, :optional, :str_to_bool],
    [:use_js_routes_middleware, :bool, :optional, :str_to_bool],
  )

  m_config = Maybe(Config.call(APP_CONFIG.to_h))

  m_config[:asset_host].each { |asset_host|
    config.action_controller.asset_host = asset_host
  }

  m_config[:eager_load].each { |eager_load|
    config.eager_load = eager_load
  }

  m_config[:serve_static_files].each { |serve_static_files|
    config.serve_static_files = serve_static_files
  }

  m_config[:log_level].each { |log_level|
    config.log_level = log_level
  }

  m_config[:use_i18n_js_middleware].each { |use_middleware|
    config.middleware.use I18n::JS::Middleware if use_middleware
  }

  m_config[:use_js_routes_middleware].each { |use_middleware|
    config.middleware.use JsRoutes::Middleware if use_middleware
  }
end
