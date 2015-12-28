Kassi::Application.configure do

  Maybe(APP_CONFIG.asset_host).each { |asset_host|
    config.action_controller.asset_host = asset_host
  }

end
