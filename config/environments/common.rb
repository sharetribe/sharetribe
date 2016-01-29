Kassi::Application.configure do

  Config = EntityUtils.define_builder(
    [:asset_host, :string, :optional],
    [:eager_load, :bool, :mandatory, :str_to_bool]
  )

  m_config = Maybe(Config.call(APP_CONFIG.to_h))

  m_config[:asset_host].each { |asset_host|
    config.action_controller.asset_host = asset_host
  }

  m_config[:eager_load].each { |eager_load|
    config.eager_load = eager_load
  }
end
